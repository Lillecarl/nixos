#!/usr/bin/env python3

"""
Keyboard/Input Device Remapper

This module provides a comprehensive input device remapping system that can:
- Map keyboard keys to different keys (e.g., CapsLock -> Ctrl)
- Handle macro pads with complex functions (VM control, display switching, etc.)
- Create virtual output devices to avoid conflicts
- Track device state and handle edge cases like stuck keys

The system uses evdev for low-level input handling and creates virtual devices
for output, allowing for complex remapping scenarios without interfering with
the original input devices.

Key Design Principles:
1. Hash-based device identification for reliable device matching
2. Async architecture for handling multiple devices simultaneously
3. Pluggable remapper classes for different device types
4. Comprehensive error handling and cleanup
5. VM and display control integration for gaming/work switching

Main Components:
- DeviceManager: Scans and manages input devices
- BaseEventRemapper: Abstract base class for all remappers
- StandardKeyboardRemapper: Common keyboard remappings
- MacropadRemapper: Complex macro functions
- RemapperManager: Orchestrates multiple remappers
"""

import argparse
import asyncio
import hashlib
import logging
import os
import time
import pygame
from abc import ABC, abstractmethod
from collections import defaultdict
from enum import IntEnum, auto
from functools import partial
from pathlib import Path
from typing import Callable, Dict, List, Optional, Sequence

import evdev
import sh
import sys
from evdev import ecodes

# Configuration - VM name for libvirt operations
DOMNAME = "win11-4"

# Common arguments for shell commands via sh library
# _async: Run commands asynchronously
# _timeout: 5 second timeout for commands
# _tee: Print command output to stdout as well as capturing it
_shargs = {
    "_async": True,
    "_timeout": 5,
    "_tee": True,
}

# Pre-configured shell command wrappers for system control
volumectl = partial(sh.volumectl, **_shargs)  # Volume control # type: ignore
ddcutil = partial(sh.ddcutil, **_shargs)      # Display control via DDC/CI # type: ignore
virsh = partial(sh.virsh, **_shargs)          # libvirt VM management # type: ignore
lsusb = partial(sh.lsusb, **_shargs)          # USB device listing # type: ignore
wpctl = partial(sh.wpctl, **_shargs)          # PipeWire control # type: ignore

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


class AsyncTaskQueue:
    """Manages async tasks in a queue for processing"""

    def __init__(self, max_concurrent: int = 10):
        self.queue = asyncio.Queue()
        self.active_tasks = set()
        self.max_concurrent = max_concurrent
        self.running = False

    async def start(self):
        """Start the queue processor"""
        self.running = True
        asyncio.create_task(self._process_queue())

    async def stop(self):
        """Stop the queue processor"""
        self.running = False
        for task in self.active_tasks:
            task.cancel()
        await asyncio.gather(*self.active_tasks, return_exceptions=True)

    async def add_task(self, coro_func: Callable, *args, **kwargs):
        """Add a coroutine function to the queue"""
        await self.queue.put((coro_func, args, kwargs))

    async def _process_queue(self):
        """Process tasks from the queue"""
        while self.running:
            try:
                if len(self.active_tasks) >= self.max_concurrent:
                    await asyncio.sleep(0.1)
                    continue

                try:
                    coro_func, args, kwargs = await asyncio.wait_for(
                        self.queue.get(), timeout=1.0
                    )
                except asyncio.TimeoutError:
                    continue

                task = asyncio.create_task(coro_func(*args, **kwargs))
                self.active_tasks.add(task)
                task.add_done_callback(self.active_tasks.discard)

            except Exception as e:
                logger.error(f"Error in queue processor: {e}")


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
    """Base class for event remappers"""

    def __init__(
        self, device_info: DeviceInfo, task_queue: AsyncTaskQueue, name_suffix: str = ""
    ):
        self.device_info = device_info
        self.input_device = device_info.device
        self.task_queue = task_queue
        self.keys_state = {}
        self.debug = os.getenv("INPUT_DEBUG", "false") in ["true", "yes", "1"]
        self.running = False

        # Create device manager for this remapper
        self.device_manager = DeviceManager()
        self.output_device = self.device_manager.create_virtual_device(
            self.input_device, name_suffix
        )

    @abstractmethod
    async def handle_event(self, event: evdev.InputEvent) -> bool:
        """
        Handle an input event. Return True if event was handled, False to pass through.
        Must be implemented by subclasses.
        """
        pass

    async def on_start(self):
        """Called when remapper starts. Override for initialization."""
        pass

    async def on_stop(self):
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

    async def run(self):
        """Main event processing loop"""
        self.running = True
        await self.on_start()

        try:
            with self.input_device.grab_context():
                logger.info(f"Started remapper for {self.device_info}")
                async for event in self.input_device.async_read_loop():
                    if not self.running:
                        break

                    try:
                        # Let subclass handle the event
                        handled = await self.handle_event(event)

                        # If not handled, pass through
                        if not handled:
                            self.write_event(event)

                    except Exception as e:
                        logger.error(f"Error handling event: {e}")
                        # Pass through on error
                        self.write_event(event)

        except asyncio.CancelledError:
            logger.info(f"Remapper cancelled for {self.device_info}")
        finally:
            self.running = False
            await self.on_stop()

    async def stop(self):
        """Stop the remapper"""
        self.running = False
        self.release_all_output_keys()


class StandardKeyboardRemapper(BaseEventRemapper):
    """Standard keyboard remapper with CapsLock->Ctrl and other common remappings"""

    def __init__(self, device_info: DeviceInfo, task_queue: AsyncTaskQueue):
        super().__init__(device_info, task_queue, "_standard")
        self.gaming_mode = False
        self.caps_esc_threshold = 0.5

    async def handle_event(self, event: evdev.InputEvent) -> bool:
        """Handle keyboard events with standard remapping"""
        if event.type != ecodes.EV_KEY:
            return False  # Pass through non-key events

        # Exit combination: ESC + END
        if self._is_input_key_active(ecodes.KEY_ESC) and self._is_input_key_active(
            ecodes.KEY_END
        ):
            await self.task_queue.add_task(self._shutdown)
            return True

        key_state = self.update_key_state(event)

        if self.debug and (
            event.value != Action.HOLD or key_state[State.HOLDCOUNT] == 1
        ):
            logger.debug(f"[{self.device_info.hash}] Input: {evdev.categorize(event)}")

        # Handle remapping
        return await self._handle_remapping(event, key_state)

    async def _handle_remapping(self, event: evdev.InputEvent, key_state: Dict) -> bool:
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

    async def _shutdown(self):
        """Shutdown signal"""
        logger.info(f"[{self.device_info.hash}] Shutdown requested")
        await self.stop()


class MacropadRemapper(BaseEventRemapper):
    """Remapper for macropad devices"""

    def __init__(self, device_info: DeviceInfo, task_queue: AsyncTaskQueue):
        super().__init__(device_info, task_queue, "_macropad")
        pygame.mixer.init()
        pygame.mixer.music.load("/home/lillecarl/Documents/kbnotification.mp3")

    async def handle_event(self, event: evdev.InputEvent) -> bool:
        """Handle macropad events"""
        if event.type != ecodes.EV_KEY or event.value != Action.UP:
            return True  # Consume all non-UP key events

        await self._process_macropad_event(event)
        return True  # Always consume macropad events

    async def _process_macropad_event(self, event: evdev.InputEvent):
        """Process macropad key events"""
        active_keys = self.input_device.active_keys()

        if event.code == ecodes.KEY_KP0:
            async def play_notification():
                # await self.task_queue.add_task(self.attach_gaming_devices)
                sysvolstr = await wpctl("get-volume", "@DEFAULT_AUDIO_SINK@")
                sysvolmul = float(sysvolstr.split()[1])
                outvolmul = 0.1 / max(sysvolmul / 2, 0.1)
                logger.info(f"KP0: Playing notification. sysvolmul: {sysvolmul} outvolmul: {outvolmul}")
                pygame.mixer.music.set_volume(outvolmul)
                pygame.mixer.music.play()

            await self.task_queue.add_task(play_notification)
        elif ecodes.KEY_KP0 in active_keys:
            if event.code == ecodes.KEY_KP1:
                await self.task_queue.add_task(VMController.start_vm, DOMNAME)
            elif event.code == ecodes.KEY_KP2:
                await self.task_queue.add_task(VMController.stop_vm, DOMNAME)
            elif event.code == ecodes.KEY_KPPLUS:
                await self.task_queue.add_task(self.change_brightness, 10)
            elif event.code == ecodes.KEY_KPMINUS:
                await self.task_queue.add_task(self.change_brightness, -10)
        elif event.code == ecodes.KEY_KP1:
            await self.task_queue.add_task(self.attach_gaming_devices)
        elif event.code == ecodes.KEY_KP2:
            await self.task_queue.add_task(self.detach_gaming_devices)
        elif event.code == ecodes.KEY_KP4:
            await self.task_queue.add_task(DisplayController.set_dp)
        elif event.code == ecodes.KEY_KP5:
            await self.task_queue.add_task(DisplayController.set_hdmi)
        elif event.code == ecodes.KEY_KPPLUS:
            await self.task_queue.add_task(self._volume_up)
        elif event.code == ecodes.KEY_KPMINUS:
            await self.task_queue.add_task(self._volume_down)

    async def _set_gamingdevices(self, attach: bool):
        """Attach gaming devices to VM"""
        devices = [
            ("2dc8", "310a"),  # 8bitdo
            ("2dc8", "310c"),  # 8bitdo idle
            ("1c4f", "0083"),  # shitkeyboard
            ("258a", "0033"),  # glorious-mouse
        ]

        for device in devices:
            await self.task_queue.add_task(
                VMController._set_device,
                DOMNAME,
                attach,
                device[0],
                device[1],
            )

    async def attach_gaming_devices(self):
        """Attach gaming devices to VM"""
        await self._set_gamingdevices(True)

    async def detach_gaming_devices(self):
        """Attach gaming devices to VM"""
        await self._set_gamingdevices(False)

    async def _volume_up(self):
        """Increase system volume"""
        await volumectl("+")

    async def _volume_down(self):
        """Decrease system volume"""
        await volumectl("-")

    async def change_brightness(self, delta: int):
        """Change display brightness by delta amount using ddcutil"""
        try:
            logger.info(f"Changing display brightness by {delta}")
            # Get current brightness value
            result = await ddcutil("-d", "1", "getvcp", "0x10", "--brief")
            # Parse output: "VCP 10 C 50 100"
            parts = result.strip().split()
            current_value = int(parts[3])  # Current value is at index 3
            max_value = int(parts[4])      # Max value is at index 4
            
            # Calculate new value within bounds
            new_value = max(0, min(current_value + delta, max_value))
            
            # Set new brightness value
            await ddcutil("-d", "1", "setvcp", "0x10", str(new_value))
            logger.info(f"Brightness changed from {current_value} to {new_value}")
        except Exception as e:
            logger.error(f"Failed to change brightness: {e}")


class DisplayController:
    """Handles display control operations"""

    @staticmethod
    async def get_vcp():
        """Get current VCP value"""
        try:
            result = await ddcutil("--model=XWU-CBA", "getvcp", "0x60", "--brief")
            for line in result.splitlines():
                if line.startswith("VCP"):
                    return line
        except Exception as e:
            logger.error(f"Failed to get VCP: {e}")
        return None

    @staticmethod
    async def set_hdmi():
        """Set display input to HDMI"""
        try:
            logger.info("Setting input to HDMI")
            await ddcutil("--model=XWU-CBA", "setvcp", "0x60", "0x0f")
        except Exception as e:
            logger.error(f"Failed to set HDMI: {e}")

    @staticmethod
    async def set_dp():
        """Set display input to DisplayPort"""
        try:
            logger.info("Setting input to DP")
            await ddcutil("--model=XWU-CBA", "setvcp", "0x60", "0x11")
        except Exception as e:
            logger.error(f"Failed to set DP: {e}")

    @staticmethod
    async def switch_input():
        """Switch display input between HDMI and DP"""
        current_vcp = await DisplayController.get_vcp()
        if current_vcp:
            if "VCP 60 SNC x00" in current_vcp:
                await DisplayController.set_dp()
            elif "VCP 60 SNC x0f" in current_vcp:
                await DisplayController.set_hdmi()


class VMController:
    """Handles VM operations"""

    @staticmethod
    async def create_usbxml(vendorid: str, productid: str):
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
    async def _set_device(vm: str, attach: bool, vendorid: str, productid: str):
        action = "attach-device" if attach else "detach-device"
        xml_path = await VMController.create_usbxml(vendorid, productid)
        try:
            await virsh(action, vm, xml_path, "--live")
            logger.info(f"{action} {xml_path} to {vm}")
        except sh.ErrorReturnCode as e:
            logger.error(f"Failed to {action} {xml_path} to {vm}: {e.stderr.decode()}")

    @staticmethod
    async def attach_device(vm: str, vendorid: str, productid: str):
        """Attach device to VM"""
        return await VMController._set_device(vm, True, vendorid, productid)

    @staticmethod
    async def detach_device(vm: str, vendorid: str, productid: str):
        """Detach device from VM"""
        return await VMController._set_device(vm, False, vendorid, productid)

    @staticmethod
    async def start_vm(vm: str):
        """Start VM"""
        try:
            await virsh("start", vm)
            logger.info(f"Started {vm}")
        except sh.ErrorReturnCode as e:
            logger.error(f"Failed to start {vm}: {e.stderr.decode()}")

    @staticmethod
    async def stop_vm(vm: str):
        """Stop VM gracefully"""
        try:
            await virsh("destroy", "--graceful", vm)
            logger.info(f"Stopped {vm}")
        except sh.ErrorReturnCode as e:
            logger.error(f"Failed to stop {vm}: {e.stderr.decode()}")


class RemapperManager:
    """Manages multiple remappers"""

    def __init__(self):
        self.device_manager = DeviceManager()
        self.task_queue = AsyncTaskQueue()
        self.remappers: List[BaseEventRemapper] = []
        self.running = False
        self.cleanup_task = None

    async def initialize(self):
        """Initialize the manager"""
        await self.task_queue.start()

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

    async def run(self):
        """Run all remappers"""
        if not self.remappers:
            logger.error("No remappers configured")
            return

        self.running = True

        # Start cleanup timer
        self.cleanup_task = asyncio.create_task(self._cleanup_timer())

        # Start all remappers
        tasks = [asyncio.create_task(remapper.run()) for remapper in self.remappers]
        tasks.append(self.cleanup_task)

        try:
            await asyncio.gather(*tasks)
        except asyncio.CancelledError:
            logger.info("Remapper manager cancelled")
        finally:
            await self.cleanup()

    async def cleanup(self):
        """Clean up all resources"""
        self.running = False

        # Stop all remappers
        for remapper in self.remappers:
            await remapper.stop()

        # Stop cleanup timer
        if self.cleanup_task:
            self.cleanup_task.cancel()

        await self.task_queue.stop()

    async def _cleanup_timer(self):
        """Timer that runs every 10 seconds to release stuck keys"""
        while self.running:
            try:
                await asyncio.sleep(10)

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

            except asyncio.CancelledError:
                break
            except Exception as e:
                logger.error(f"Error in cleanup timer: {e}")


def parse_args():
    """Parse command line arguments"""
    parser = argparse.ArgumentParser(
        description="Keyboard remapper with device hash identification",
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


async def main():
    """Main entry point"""
    args = parse_args()

    if args.debug:
        logging.getLogger().setLevel(logging.DEBUG)

    manager = RemapperManager()

    if args.list or not args.devices:
        manager.list_devices()
        return

    await manager.initialize()

    for spec in args.devices:
        # Format: device_identifier[:type]
        parts = spec.split(":")
        device_id = parts[0]
        remapper_type = parts[1] if len(parts) > 1 else "standard"

        # if remapper_type == "standard":
        #     remapper = manager.create_standard_remapper(device_id)
        # elif remapper_type == "macropad":
        #     remapper = manager.create_macropad_remapper(device_id)
        # else:
        #     logger.error(f"Unknown remapper type: {remapper_type}")
        #     continue

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
        await manager.run()
    except Exception as e:
        logger.error(f"Application error: {e}")
        raise
    finally:
        await manager.cleanup()


if __name__ == "__main__":
    sys.dont_write_bytecode = True
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        logger.info("Interrupted by user")
    except asyncio.CancelledError:
        logger.info("Application cancelled")
    except Exception as ex:
        logger.info(ex)
