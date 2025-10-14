#!/usr/bin/env python3

"""
Keyboard/Input Device Remapper (ZeroMQ + Threading Version)

This module provides a comprehensive input device remapping system that uses:
- ZeroMQ inproc transport for communication between threads
- Worker threads that spawn on demand
- Thread-based architecture instead of asyncio

Key Design Changes from Original:
1. ZeroMQ inproc sockets for inter-thread communication
2. Worker threads spawn on-demand for handling tasks
3. ThreadPoolExecutor for managing worker threads
4. Synchronous event handling with threading primitives

Main Components:
- DeviceManager: Scans and manages input devices (unchanged)
- ThreadTaskQueue: ZeroMQ-based task queue with worker threads
- BaseEventRemapper: Thread-based base class for all remappers
- StandardKeyboardRemapper: Common keyboard remappings (thread-based)
- MacropadRemapper: Complex macro functions (thread-based)
- RemapperManager: Orchestrates multiple remappers with threading
"""

import argparse
import hashlib
import logging
import os
import time
import pygame
import threading
import queue
import zmq
from abc import ABC, abstractmethod
from collections import defaultdict
from enum import IntEnum, auto
from functools import partial
from pathlib import Path
from typing import Callable, Dict, List, Optional, Sequence, Any
from concurrent.futures import ThreadPoolExecutor, Future
import json

import evdev
import sh
import sys
from evdev import ecodes

# Configuration - VM name for libvirt operations
DOMNAME = "win11-4"

# Common arguments for shell commands via sh library
_shargs = {
    "_timeout": 5,
    "_tee": True,
}

# Pre-configured shell command wrappers for system control
volumectl = partial(sh.volumectl, **_shargs)
ddcutil = partial(sh.ddcutil, **_shargs)
virsh = partial(sh.virsh, **_shargs)
lsusb = partial(sh.lsusb, **_shargs)
wpctl = partial(sh.wpctl, **_shargs)

# Set up logging
logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)


class Action(IntEnum):
    DOWN = 1
    UP = 0
    HOLD = 2


class State(IntEnum):
    @staticmethod
    def _generate_next_value_(name, start, count, last_values):
        return count + 1

    DOWNTIME = auto()
    HOLDTIME = auto()
    UPTIME = auto()
    VALUE = auto()
    HOLDCOUNT = auto()


class Event(IntEnum):
    SYN = 0
    KEY = 1
    REL = 2
    MSC = 4
    LED = 17
    REP = 20


class Rel(IntEnum):
    MOUSEX = 0
    MOUSEY = 1
    SCROLLX = 6
    SCROLLY = 8


class DeviceInfo:
    """Information about an input device including unique hash"""

    def __init__(self, device: evdev.InputDevice):
        self.device = device
        self.name = device.name
        self.path = device.path
        self.capabilities = device.capabilities()
        self.hash = self._generate_hash()

    def _generate_hash(self) -> str:
        """Generate unique hash from device name and capabilities"""
        hasher = hashlib.sha256()
        hasher.update(self.name.encode())

        # Sort capabilities for consistent hashing
        cap_str = str(sorted(self.capabilities.items()))
        hasher.update(cap_str.encode())

        return hasher.hexdigest()[:16]  # Use first 16 chars for readability

    def __str__(self):
        return f"{self.name} ({self.hash}) - {self.path}"


class ThreadTaskQueue:
    """ZeroMQ-based task queue with on-demand worker threads"""

    def __init__(self, max_workers: int = 10):
        self.context = zmq.Context()
        self.task_socket = self.context.socket(zmq.PUSH)
        self.result_socket = self.context.socket(zmq.PULL)

        # Bind to inproc endpoints
        self.task_endpoint = "inproc://tasks"
        self.result_endpoint = "inproc://results"

        self.task_socket.bind(self.task_endpoint)
        self.result_socket.bind(self.result_endpoint)

        self.executor = ThreadPoolExecutor(max_workers=max_workers, thread_name_prefix="TaskWorker")
        self.running = False
        self.workers: List[threading.Thread] = []
        self.active_tasks = 0
        self.lock = threading.Lock()

        # Registry for callable handlers
        self.handlers = {}
        self._register_handlers()

    def _register_handlers(self):
        """Register handlers for different types of callables"""
        self.handlers.update({
            'VMController.start_vm': VMController.start_vm,
            'VMController.stop_vm': VMController.stop_vm,
            'VMController._set_device': VMController._set_device,
            'DisplayController.set_dp': DisplayController.set_dp,
            'DisplayController.set_hdmi': DisplayController.set_hdmi,
        })

    def start(self):
        """Start the task queue"""
        self.running = True
        # Start initial worker
        self._spawn_worker()

    def stop(self):
        """Stop the task queue"""
        self.running = False

        # Send poison pill to stop workers
        for _ in self.workers:
            self.add_task_by_name("poison_pill")

        # Wait for workers to finish
        for worker in self.workers:
            worker.join(timeout=2.0)

        self.executor.shutdown(wait=True)
        self.task_socket.close()
        self.result_socket.close()
        self.context.term()

    def add_task(self, func: Callable, *args, **kwargs):
        """Add a task to the queue - finds handler name automatically"""
        if hasattr(func, '__self__'):
            # Instance method
            class_name = func.__self__.__class__.__name__
            handler_name = f"{class_name}.{func.__name__}"
        elif hasattr(func, '__qualname__'):
            # Static method or function
            handler_name = func.__qualname__
        else:
            # Function name
            handler_name = func.__name__

        self.add_task_by_name(handler_name, *args, **kwargs)

    def add_task_by_name(self, handler_name: str, *args, **kwargs):
        """Add a task to the queue by handler name"""
        task_data = {
            "handler": handler_name,
            "args": list(args),
            "kwargs": kwargs,
            "poison_pill": handler_name == "poison_pill"
        }

        # Send task via ZeroMQ
        self.task_socket.send_json(task_data, zmq.NOBLOCK)

        # Check if we need more workers
        with self.lock:
            self.active_tasks += 1
            if handler_name != "poison_pill" and self.active_tasks > len(self.workers) and len(self.workers) < self.executor._max_workers:
                self._spawn_worker()

    def register_handler(self, name: str, func: Callable):
        """Register a handler function"""
        self.handlers[name] = func

    def _spawn_worker(self):
        """Spawn a new worker thread on demand"""
        worker_id = len(self.workers)
        worker = threading.Thread(target=self._worker_loop, args=(worker_id,), daemon=True)
        self.workers.append(worker)
        worker.start()
        logger.debug(f"Spawned worker thread {worker_id}")

    def _worker_loop(self, worker_id: int):
        """Worker thread loop that processes tasks from ZeroMQ"""
        # Create worker socket
        worker_socket = self.context.socket(zmq.PULL)
        worker_socket.connect(self.task_endpoint)

        logger.debug(f"Worker {worker_id} started")

        while self.running:
            try:
                # Poll for tasks with timeout
                if worker_socket.poll(timeout=1000):  # 1 second timeout
                    task_data = worker_socket.recv_json(zmq.NOBLOCK)

                    if task_data.get("poison_pill", False):
                        logger.debug(f"Worker {worker_id} received poison pill")
                        break

                    # Execute the task
                    try:
                        handler_name = task_data["handler"]
                        args = task_data["args"]
                        kwargs = task_data["kwargs"]

                        if handler_name in self.handlers:
                            func = self.handlers[handler_name]
                            # Run in thread pool to avoid blocking the worker
                            future = self.executor.submit(func, *args, **kwargs)
                            result = future.result(timeout=30)  # 30 second timeout for individual tasks
                        else:
                            logger.error(f"Unknown handler: {handler_name}")

                    except Exception as e:
                        logger.error(f"Worker {worker_id} task error: {e}")
                    finally:
                        with self.lock:
                            self.active_tasks = max(0, self.active_tasks - 1)

            except zmq.Again:
                # Timeout, continue loop
                continue
            except Exception as e:
                logger.error(f"Worker {worker_id} error: {e}")

        worker_socket.close()
        logger.debug(f"Worker {worker_id} stopped")


class DeviceManager:
    """Manages input and output devices with hash-based identification"""

    def __init__(self):
        self.devices: List[DeviceInfo] = []
        self._scan_devices()

    def _scan_devices(self):
        """Scan and catalog all available input devices"""
        self.devices = []
        for path in evdev.list_devices():
            try:
                device = evdev.InputDevice(path)
                try:
                    self.devices.append(DeviceInfo(device))
                except Exception as e:
                    logger.error(e)
                    continue
            except Exception as e:
                logger.warning(f"Could not access device {path}: {e}")

    def list_devices(self) -> List[DeviceInfo]:
        """List all available devices with their hashes"""
        return self.devices

    def find_device_by_name(self, name: str) -> Optional[DeviceInfo]:
        """Find device by exact name match"""
        for device_info in self.devices:
            if device_info.name == name:
                return device_info
        return None

    def find_device_by_hash(self, device_hash: str) -> Optional[DeviceInfo]:
        """Find device by hash"""
        for device_info in self.devices:
            if device_info.hash == device_hash:
                return device_info
        return None

    def find_device_by_partial_hash(self, partial_hash: str) -> List[DeviceInfo]:
        """Find devices by partial hash match"""
        matches = []
        for device_info in self.devices:
            if device_info.hash.startswith(partial_hash.lower()):
                matches.append(device_info)
        return matches

    def create_virtual_device(
        self, input_device: evdev.InputDevice, name_suffix: str = ""
    ) -> evdev.UInput:
        """Create virtual output device based on input device capabilities"""
        all_capabilities = defaultdict(set)

        for ev_type, ev_codes in input_device.capabilities().items():
            all_capabilities[ev_type].update(ev_codes)

        all_capabilities[ecodes.EV_REL].update(
            [Rel.MOUSEX, Rel.MOUSEY, Rel.SCROLLX, Rel.SCROLLY]
        )

        if ecodes.EV_SYN in all_capabilities:
            del all_capabilities[ecodes.EV_SYN]

        device_name = f"pykbd{name_suffix}"
        result: Dict[int, Sequence[int]] = {
            k: list(v) for k, v in all_capabilities.items()
        }
        udev = evdev.UInput(events=result, name=device_name)

        symlink_path = f"/dev/input/{device_name}"
        Path(symlink_path).unlink(missing_ok=True)
        Path(symlink_path).symlink_to(udev.device.path, False)

        logger.info(f"Created virtual device: {device_name} -> {udev.device.path}")
        return udev


class BaseEventRemapper(ABC):
    """Base class for event remappers using threading"""

    def __init__(
        self, device_info: DeviceInfo, task_queue: ThreadTaskQueue, name_suffix: str = ""
    ):
        self.device_info = device_info
        self.input_device = device_info.device
        self.task_queue = task_queue
        self.keys_state = {}
        self.debug = os.getenv("INPUT_DEBUG", "false") in ["true", "yes", "1"]
        self.running = False
        self.stop_event = threading.Event()

        # Create device manager for this remapper
        self.device_manager = DeviceManager()
        self.output_device = self.device_manager.create_virtual_device(
            self.input_device, name_suffix
        )

    @abstractmethod
    def handle_event(self, event: evdev.InputEvent) -> bool:
        """
        Handle an input event. Return True if event was handled, False to pass through.
        Must be implemented by subclasses.
        """
        pass

    def on_start(self):
        """Called when remapper starts. Override for initialization."""
        pass

    def on_stop(self):
        """Called when remapper stops. Override for cleanup."""
        pass

    def update_key_state(self, event: evdev.InputEvent) -> Dict:
        """Update internal key state tracking"""
        if self.keys_state.get(event.code) is None:
            itime = time.time() - 60
            self.keys_state[event.code] = {
                State.VALUE: event.value,
                State.DOWNTIME: itime,
                State.HOLDTIME: itime,
                State.UPTIME: itime,
                State.HOLDCOUNT: 0,
            }

        key_state = self.keys_state[event.code]
        key_state[State.VALUE] = event.value

        if event.value == Action.DOWN:
            key_state[State.DOWNTIME] = event.timestamp()
        elif event.value == Action.HOLD:
            key_state[State.HOLDTIME] = event.timestamp()
            key_state[State.HOLDCOUNT] += 1
        elif event.value == Action.UP:
            key_state[State.UPTIME] = event.timestamp()
            key_state[State.HOLDCOUNT] = 0

        return key_state

    def write_event(self, event: evdev.InputEvent, syn: bool = True) -> bool:
        """Write event to output device"""
        if not self._can_write_up(event.type, event.code, event.value):
            return False

        self.output_device.write_event(event)
        if syn:
            self.output_device.syn()

        if self.debug:
            logger.debug(f"[{self.device_info.hash}] Output: {evdev.categorize(event)}")
        return True

    def _can_write_up(self, etype, code, value) -> bool:
        """Check if UP event can be written"""
        if value != Action.UP:
            return True
        return (
            etype == ecodes.EV_KEY
            and value == Action.UP
            and self._is_output_key_active(code)
        )

    def _is_input_key_active(self, key: int) -> bool:
        """Check if key is active on input device"""
        return any(e == key for e in self.input_device.active_keys())

    def _is_output_key_active(self, key: int) -> bool:
        """Check if key is active on output device"""
        output_device = evdev.InputDevice(self.output_device.device.path)
        return any(e == key for e in output_device.active_keys())

    def press_key(self, code):
        """Press key"""
        self.write_event(evdev.InputEvent(0, 0, ecodes.EV_KEY, code, Action.DOWN))

    def release_key(self, code):
        """Release key"""
        self.write_event(evdev.InputEvent(0, 0, ecodes.EV_KEY, code, Action.UP))

    def tap_key(self, code):
        """Press and release key"""
        self.press_key(code)
        self.release_key(code)

    def release_all_output_keys(self):
        """Release all currently active output keys"""
        output_device = evdev.InputDevice(self.output_device.device.path)
        active_keys = output_device.active_keys()
        if active_keys:
            logger.info(
                f"[{self.device_info.hash}] Releasing {len(active_keys)} stuck output keys"
            )
            for key_id in active_keys:
                self.release_key(key_id)

    def run(self):
        """Main event processing loop (synchronous, thread-based)"""
        self.running = True
        self.on_start()

        try:
            with self.input_device.grab_context():
                logger.info(f"Started remapper for {self.device_info}")

                for event in self.input_device.read_loop():
                    if self.stop_event.is_set():
                        break

                    try:
                        # Let subclass handle the event
                        handled = self.handle_event(event)

                        # If not handled, pass through
                        if not handled:
                            self.write_event(event)

                    except Exception as e:
                        logger.error(f"Error handling event: {e}")
                        # Pass through on error
                        self.write_event(event)

        except Exception as e:
            logger.info(f"Remapper stopped for {self.device_info}: {e}")
        finally:
            self.running = False
            self.on_stop()

    def stop(self):
        """Stop the remapper"""
        self.running = False
        self.stop_event.set()
        self.release_all_output_keys()


class StandardKeyboardRemapper(BaseEventRemapper):
    """Standard keyboard remapper with CapsLock->Ctrl and other common remappings"""

    def __init__(self, device_info: DeviceInfo, task_queue: ThreadTaskQueue):
        super().__init__(device_info, task_queue, "_standard")
        self.gaming_mode = False
        self.caps_esc_threshold = 0.5

    def handle_event(self, event: evdev.InputEvent) -> bool:
        """Handle keyboard events with standard remapping"""
        if event.type != ecodes.EV_KEY:
            return False  # Pass through non-key events

        # Exit combination: ESC + END
        if self._is_input_key_active(ecodes.KEY_ESC) and self._is_input_key_active(
            ecodes.KEY_END
        ):
            self._shutdown()
            return True

        key_state = self.update_key_state(event)

        if self.debug and (
            event.value != Action.HOLD or key_state[State.HOLDCOUNT] == 1
        ):
            logger.debug(f"[{self.device_info.hash}] Input: {evdev.categorize(event)}")

        # Handle remapping
        return self._handle_remapping(event, key_state)

    def _handle_remapping(self, event: evdev.InputEvent, key_state: Dict) -> bool:
        """Handle key remapping logic"""
        # CapsLock -> Ctrl, tap for Esc
        if event.code == ecodes.KEY_CAPSLOCK:
            event.code = ecodes.KEY_LEFTCTRL
            self.write_event(event)

            if (
                event.value == Action.UP
                and time.time() - key_state[State.DOWNTIME] < self.caps_esc_threshold
            ):
                self.tap_key(ecodes.KEY_ESC)
            return True

        # Caps + ESC -> CapsLock
        if (
            event.code == ecodes.KEY_ESC
            and event.value == Action.DOWN
            and self._is_input_key_active(ecodes.KEY_CAPSLOCK)
        ):
            self.tap_key(ecodes.KEY_CAPSLOCK)
            return True

        return False

    def _shutdown(self):
        """Shutdown signal"""
        logger.info(f"[{self.device_info.hash}] Shutdown requested")
        self.stop()


class MacropadRemapper(BaseEventRemapper):
    """Remapper for macropad devices"""

    def __init__(self, device_info: DeviceInfo, task_queue: ThreadTaskQueue):
        super().__init__(device_info, task_queue, "_macropad")
        pygame.mixer.init()
        pygame.mixer.music.load("/home/lillecarl/Documents/kbnotification.mp3")

        # Register instance methods with the task queue
        task_queue.register_handler("MacropadRemapper.play_notification", self.play_notification)
        task_queue.register_handler("MacropadRemapper.attach_gaming_devices", self.attach_gaming_devices)
        task_queue.register_handler("MacropadRemapper.detach_gaming_devices", self.detach_gaming_devices)
        task_queue.register_handler("MacropadRemapper._volume_up", self._volume_up)
        task_queue.register_handler("MacropadRemapper._volume_down", self._volume_down)
        task_queue.register_handler("MacropadRemapper.change_brightness", self.change_brightness)

    def handle_event(self, event: evdev.InputEvent) -> bool:
        """Handle macropad events"""
        if event.type != ecodes.EV_KEY or event.value != Action.UP:
            return True  # Consume all non-UP key events

        self._process_macropad_event(event)
        return True  # Always consume macropad events

    def _process_macropad_event(self, event: evdev.InputEvent):
        """Process macropad key events"""
        active_keys = self.input_device.active_keys()

        if event.code == ecodes.KEY_KP0:
            self.tap_key(ecodes.KEY_SPACE)
            self.task_queue.add_task_by_name("MacropadRemapper.play_notification")
        elif ecodes.KEY_KP0 in active_keys:
            if event.code == ecodes.KEY_KP1:
                self.task_queue.add_task_by_name("VMController.start_vm", DOMNAME)
            elif event.code == ecodes.KEY_KP2:
                self.task_queue.add_task_by_name("VMController.stop_vm", DOMNAME)
            elif event.code == ecodes.KEY_KPPLUS:
                self.task_queue.add_task_by_name("MacropadRemapper.change_brightness", 10)
            elif event.code == ecodes.KEY_KPMINUS:
                self.task_queue.add_task_by_name("MacropadRemapper.change_brightness", -10)
        elif event.code == ecodes.KEY_KP1:
            self.task_queue.add_task_by_name("MacropadRemapper.attach_gaming_devices")
        elif event.code == ecodes.KEY_KP2:
            self.task_queue.add_task_by_name("MacropadRemapper.detach_gaming_devices")
        elif event.code == ecodes.KEY_KP4:
            self.task_queue.add_task_by_name("DisplayController.set_dp")
        elif event.code == ecodes.KEY_KP5:
            self.task_queue.add_task_by_name("DisplayController.set_hdmi")
        elif event.code == ecodes.KEY_KPPLUS:
            self.task_queue.add_task_by_name("MacropadRemapper._volume_up")
        elif event.code == ecodes.KEY_KPMINUS:
            self.task_queue.add_task_by_name("MacropadRemapper._volume_down")

    def play_notification(self):
        """Play notification sound"""
        try:
            sysvolstr = str(wpctl("get-volume", "@DEFAULT_AUDIO_SINK@"))
            sysvolmul = float(sysvolstr.split()[1])
            outvolmul = 0.1 / max(sysvolmul / 2, 0.1)
            logger.info(f"KP0: Playing notification. sysvolmul: {sysvolmul:.2f} outvolmul: {outvolmul:.2f}")
            pygame.mixer.music.set_volume(outvolmul)
            pygame.mixer.music.play()
        except Exception as e:
            logger.error(f"Failed to play notification: {e}")

    def _set_gamingdevices(self, attach: bool):
        """Attach gaming devices to VM"""
        devices = [
            ("2dc8", "310a"),  # 8bitdo
            ("2dc8", "310c"),  # 8bitdo idle
            ("1c4f", "0083"),  # shitkeyboard
            ("258a", "0033"),  # glorious-mouse
        ]

        for device in devices:
            self.task_queue.add_task_by_name(
                "VMController._set_device",
                DOMNAME,
                attach,
                device[0],
                device[1],
            )

    def attach_gaming_devices(self):
        """Attach gaming devices to VM"""
        self._set_gamingdevices(True)

    def detach_gaming_devices(self):
        """Detach gaming devices from VM"""
        self._set_gamingdevices(False)

    def _volume_up(self):
        """Increase system volume"""
        try:
            volumectl("+")
        except Exception as e:
            logger.error(f"Failed to increase volume: {e}")

    def _volume_down(self):
        """Decrease system volume"""
        try:
            volumectl("-")
        except Exception as e:
            logger.error(f"Failed to decrease volume: {e}")

    def change_brightness(self, delta: int):
        """Change display brightness by delta amount using ddcutil"""
        try:
            huawei = "BenQ XL2430T"
            benq = "XWU-CBA"

            logger.info(f"Changing display brightness by {delta}")
            # Get current brightness value for display 1
            result = str(ddcutil("--model", huawei, "getvcp", "0x10", "--brief"))
            # Parse output: "VCP 10 C 50 100"
            parts = result.strip().split()
            current_value = int(parts[3])  # Current value is at index 3
            max_value = int(parts[4])      # Max value is at index 4

            # Calculate new value within bounds for display 1
            new_value = max(0, min(current_value + delta, max_value))

            # Set display 2 brightness to 25 more than display 1, respecting 100 maximum
            display2_value = min(new_value + 25, 100)

            # Execute setvcp commands
            ddcutil("--model", huawei, "setvcp", "0x10", str(new_value))
            ddcutil("--model", benq, "setvcp", "0x10", str(display2_value))

            logger.info(f"Display {huawei} brightness changed from {current_value} to {new_value}")
            logger.info(f"Display {benq} brightness set to {display2_value}")
        except Exception as e:
            logger.error(f"Failed to change brightness: {e}")


class DisplayController:
    """Handles display control operations"""

    @staticmethod
    def get_vcp():
        """Get current VCP value"""
        try:
            result = str(ddcutil("--model=XWU-CBA", "getvcp", "0x60", "--brief"))
            for line in result.splitlines():
                if line.startswith("VCP"):
                    return line
        except Exception as e:
            logger.error(f"Failed to get VCP: {e}")
        return None

    @staticmethod
    def set_hdmi():
        """Set display input to HDMI"""
        try:
            logger.info("Setting input to HDMI")
            ddcutil("--model=XWU-CBA", "setvcp", "0x60", "0x0f")
        except Exception as e:
            logger.error(f"Failed to set HDMI: {e}")

    @staticmethod
    def set_dp():
        """Set display input to DisplayPort"""
        try:
            logger.info("Setting input to DP")
            ddcutil("--model=XWU-CBA", "setvcp", "0x60", "0x11")
        except Exception as e:
            logger.error(f"Failed to set DP: {e}")

    @staticmethod
    def switch_input():
        """Switch display input between HDMI and DP"""
        current_vcp = DisplayController.get_vcp()
        if current_vcp:
            if "VCP 60 SNC x00" in current_vcp:
                DisplayController.set_dp()
            elif "VCP 60 SNC x0f" in current_vcp:
                DisplayController.set_hdmi()


class VMController:
    """Handles VM operations"""

    @staticmethod
    def create_usbxml(vendorid: str, productid: str):
        xmlPath = Path(f"/tmp/{vendorid}:{productid}.xml")
        xmlPath.write_text(
            f"""
<hostdev mode="subsystem" type="usb" managed="yes">
  <source>
    <vendor id="0x{vendorid}"/>
    <product id="0x{productid}"/>
  </source>
</hostdev>
""".lstrip()
        )
        return xmlPath

    @staticmethod
    def _set_device(vm: str, attach: bool, vendorid: str, productid: str):
        action = "attach-device" if attach else "detach-device"
        xml_path = VMController.create_usbxml(vendorid, productid)
        try:
            virsh(action, vm, xml_path, "--live")
            logger.info(f"{action} {xml_path} to {vm}")
        except sh.ErrorReturnCode as e:
            logger.error(f"Failed to {action} {xml_path} to {vm}: {e.stderr.decode()}")

    @staticmethod
    def attach_device(vm: str, vendorid: str, productid: str):
        """Attach device to VM"""
        return VMController._set_device(vm, True, vendorid, productid)

    @staticmethod
    def detach_device(vm: str, vendorid: str, productid: str):
        """Detach device from VM"""
        return VMController._set_device(vm, False, vendorid, productid)

    @staticmethod
    def start_vm(vm: str):
        """Start VM"""
        try:
            virsh("start", vm)
            logger.info(f"Started {vm}")
        except sh.ErrorReturnCode as e:
            logger.error(f"Failed to start {vm}: {e.stderr.decode()}")

    @staticmethod
    def stop_vm(vm: str):
        """Stop VM gracefully"""
        try:
            virsh("destroy", "--graceful", vm)
            logger.info(f"Stopped {vm}")
        except sh.ErrorReturnCode as e:
            logger.error(f"Failed to stop {vm}: {e.stderr.decode()}")


class RemapperManager:
    """Manages multiple remappers using threading"""

    def __init__(self):
        self.device_manager = DeviceManager()
        self.task_queue = ThreadTaskQueue()
        self.remappers: List[BaseEventRemapper] = []
        self.running = False
        self.cleanup_thread = None
        self.remapper_threads: List[threading.Thread] = []

    def initialize(self):
        """Initialize the manager"""
        self.task_queue.start()

    def list_devices(self):
        """List all available devices"""
        logger.info("Available devices:")
        for device_info in self.device_manager.list_devices():
            logger.info(f"  {device_info}")

    def add_remapper(self, remapper: BaseEventRemapper):
        """Add a remapper to be managed"""
        self.remappers.append(remapper)

    def create_standard_remapper(
        self, device_identifier: str
    ) -> Optional[BaseEventRemapper]:
        """Create a standard keyboard remapper for the given device"""
        device_info = self._find_device(device_identifier)
        if device_info:
            return StandardKeyboardRemapper(device_info, self.task_queue)
        return None

    def create_macropad_remapper(
        self, device_identifier: str
    ) -> Optional[BaseEventRemapper]:
        """Create a macropad remapper for the given device"""
        device_info = self._find_device(device_identifier)
        if device_info:
            return MacropadRemapper(device_info, self.task_queue)
        return None

    def _find_device(self, identifier: str) -> Optional[DeviceInfo]:
        """Find device by name or hash"""
        # Try exact hash match first
        device_info = self.device_manager.find_device_by_hash(identifier)
        if device_info:
            return device_info

        # Try partial hash match
        matches = self.device_manager.find_device_by_partial_hash(identifier)
        if len(matches) == 1:
            return matches[0]
        elif len(matches) > 1:
            logger.error(f"Multiple devices match hash '{identifier}':")
            for match in matches:
                logger.error(f"  {match}")
            return None

        # Try name match
        device_info = self.device_manager.find_device_by_name(identifier)
        if device_info:
            return device_info

        logger.error(f"Device not found: {identifier}")
        return None

    def run(self):
        """Run all remappers"""
        if not self.remappers:
            logger.error("No remappers configured")
            return

        self.running = True

        # Start cleanup timer
        self.cleanup_thread = threading.Thread(target=self._cleanup_timer, daemon=True)
        self.cleanup_thread.start()

        # Start all remappers in separate threads
        for remapper in self.remappers:
            thread = threading.Thread(target=remapper.run, daemon=True)
            self.remapper_threads.append(thread)
            thread.start()

        try:
            # Wait for all remapper threads
            for thread in self.remapper_threads:
                thread.join()
        except KeyboardInterrupt:
            logger.info("Remapper manager interrupted")
        finally:
            self.cleanup()

    def cleanup(self):
        """Clean up all resources"""
        self.running = False

        # Stop all remappers
        for remapper in self.remappers:
            remapper.stop()

        # Wait for threads to finish
        for thread in self.remapper_threads:
            thread.join(timeout=2.0)

        if self.cleanup_thread:
            self.cleanup_thread.join(timeout=2.0)

        self.task_queue.stop()

    def _cleanup_timer(self):
        """Timer that runs every 10 seconds to release stuck keys"""
        while self.running:
            try:
                time.sleep(10)

                if not self.running:
                    break

                # Check each remapper for stuck keys
                for remapper in self.remappers:
                    input_active = remapper.input_device.active_keys()
                    output_device = evdev.InputDevice(
                        remapper.output_device.device.path
                    )
                    output_active = output_device.active_keys()

                    if len(input_active) == 0 and len(output_active) > 0:
                        logger.warning(
                            f"Timer cleanup for {remapper.device_info.hash}: releasing {len(output_active)} stuck keys"
                        )
                        remapper.release_all_output_keys()

            except Exception as e:
                logger.error(f"Error in cleanup timer: {e}")


def parse_args():
    """Parse command line arguments"""
    parser = argparse.ArgumentParser(
        description="Keyboard remapper with ZeroMQ and threading",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s list                           # List all available devices
  %(prog)s "My Keyboard"                  # Use device by name
  %(prog)s a1b2c3d4e5f6g7h8               # Use device by full hash
  %(prog)s a1b2c3                        # Use device by partial hash
  %(prog)s a1b2c3:standard               # Specify remapper type
  %(prog)s "Keyboard 1" b4c5d6:macropad  # Multiple devices
        """,
    )

    parser.add_argument(
        "devices",
        nargs="*",
        help="Device identifiers (name, hash, or partial hash) with optional :type suffix",
    )

    parser.add_argument(
        "--list", "-l", action="store_true", help="List all available devices and exit"
    )

    parser.add_argument(
        "--debug", "-d", action="store_true", help="Enable debug logging"
    )

    return parser.parse_args()


def main():
    """Main entry point"""
    args = parse_args()

    if args.debug:
        logging.getLogger().setLevel(logging.DEBUG)

    manager = RemapperManager()

    if args.list or not args.devices:
        manager.list_devices()
        return

    manager.initialize()

    for spec in args.devices:
        # Format: device_identifier[:type]
        parts = spec.split(":")
        device_id = parts[0]
        remapper_type = parts[1] if len(parts) > 1 else "standard"

        remapper = manager.create_macropad_remapper(device_id)  # Only start macropad

        if remapper:
            manager.add_remapper(remapper)
            logger.info(f"Added {remapper_type} remapper for {device_id}")
        else:
            logger.error(f"Could not create remapper for {device_id}")

    if not manager.remappers:
        logger.error("No valid remappers created")
        return

    logger.info(f"Starting {len(manager.remappers)} remapper(s)")

    try:
        manager.run()
    except Exception as e:
        logger.error(f"Application error: {e}")
        raise
    finally:
        manager.cleanup()


if __name__ == "__main__":
    sys.dont_write_bytecode = True
    try:
        main()
    except KeyboardInterrupt:
        logger.info("Interrupted by user")
    except Exception as ex:
        logger.info(ex)
