#! /usr/bin/env python3

import evdev
import time
import asyncio
import os
from evdev import ecodes
from typing import Final

DOWN: Final[int] = 1
UP: Final[int] = 0
HOLD: Final[int] = 2


async def main():
    debug: bool = os.getenv("INPUT_DEBUG", "false").lower() != "false"

    selected_device: evdev.InputDevice | None = None

    devices = [evdev.InputDevice(path) for path in evdev.list_devices()]

    for device in devices:
        print(device.path, device.name, device.phys)
        if device.name == "AT Translated Set 2 keyboard":
            selected_device = device
            break

    if selected_device is None:
        print("No device found")
        return

    ui = evdev.UInput.from_device(selected_device, name="pykbd")
    print(ui.capabilities(verbose=True).keys())
    print(ui.phys)

    selected_device.grab()

    caps_esc_threshold = 0.5

    keys_state = {}

    def key_down(key: int) -> bool:
        return any(e == key for e in selected_device.active_keys())

    event: evdev.InputEvent
    async for event in selected_device.async_read_loop():
        if event.type == ecodes.EV_KEY:  # type: ignore
            if key_down(ecodes.KEY_ESC) and key_down(ecodes.KEY_END):  # type: ignore
                selected_device.ungrab()
                return

            if keys_state.get(event.code) is None:
                keys_state[event.code] = {
                    "value": event.value,
                    "downtime": time.time(),
                    "holdtime": time.time(),
                    "uptime": time.time(),
                    "holdcount": 0,
                }
            keys_state[event.code]["value"] = event.value
            if event.value == DOWN:
                keys_state[event.code]["downtime"] = time.time()
            elif event.value == HOLD:
                keys_state[event.code]["holdtime"] = time.time()
                keys_state[event.code]["holdcount"] += 1
            elif event.value == UP:
                keys_state[event.code]["uptime"] = time.time()
                keys_state[event.code]["holdcount"] = 0

            if debug and (
                event.value != HOLD or keys_state[event.code]["holdcount"] == 1
            ):
                print(evdev.categorize(event))
                print(selected_device.active_keys())

            key_state = keys_state[event.code]

            if event.code == ecodes.KEY_CAPSLOCK:  # type: ignore
                ui.write(ecodes.EV_KEY, ecodes.KEY_LEFTCTRL, event.value)  # type: ignore
                ui.syn()

                if event.value == UP:
                    if time.time() - key_state["downtime"] < caps_esc_threshold:
                        ui.write(ecodes.EV_KEY, ecodes.KEY_ESC, DOWN)  # type: ignore
                        ui.write(ecodes.EV_KEY, ecodes.KEY_ESC, UP)  # type: ignore
                        ui.syn()

                continue

            if (
                event.code == ecodes.KEY_ESC
                and event.value == DOWN
                and key_down(ecodes.KEY_CAPSLOCK)
            ):  # type: ignore
                ui.write(ecodes.EV_KEY, ecodes.KEY_CAPSLOCK, DOWN)  # type: ignore
                ui.write(ecodes.EV_KEY, ecodes.KEY_CAPSLOCK, UP)  # type: ignore

                continue

            ui.write(ecodes.EV_KEY, event.code, event.value)  # type: ignore
            ui.syn()


if __name__ == "__main__":
    asyncio.run(main())
