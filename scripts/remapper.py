#! /usr/bin/env python3

import evdev
import time
import asyncio
import os
import sys
import functools
from enum import IntEnum, auto
from collections import defaultdict
from pathlib import Path

print = functools.partial(print, flush=("SYSTEMD_EXEC_PID" in os.environ.keys()))


class Layer(IntEnum):
    @staticmethod
    def _generate_next_value_(name, start, count, last_values):
        return 2 ** (count + 1)

    NORMAL = auto()
    NUMPAD = auto()


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
    SYN = 0  # Synchronize event(s)
    KEY = 1  # Keyboard or button event(s)
    REL = 2  # Mouse or other relative event(s)
    MSC = 4
    LED = 17


class Rel(IntEnum):
    MOUSEX = 0
    MOUSEY = 1
    SCROLLX = 6
    SCROLLY = 8


class Keys(IntEnum):
    RESERVED = 0
    ESC = 1
    N1 = 2
    N2 = 3
    N3 = 4
    N4 = 5
    N5 = 6
    N6 = 7
    N7 = 8
    N8 = 9
    N9 = 10
    N0 = 11
    MINUS = 12
    EQUAL = 13
    BACKSPACE = 14
    TAB = 15
    Q = 16
    W = 17
    E = 18
    R = 19
    T = 20
    Y = 21
    U = 22
    I = 23
    O = 24
    P = 25
    LEFTBRACE = 26
    RIGHTBRACE = 27
    ENTER = 28
    LEFTCTRL = 29
    A = 30
    S = 31
    D = 32
    F = 33
    G = 34
    H = 35
    J = 36
    K = 37
    L = 38
    SEMICOLON = 39
    APOSTROPHE = 40
    GRAVE = 41
    LEFTSHIFT = 42
    BACKSLASH = 43
    Z = 44
    X = 45
    C = 46
    V = 47
    B = 48
    N = 49
    M = 50
    COMMA = 51
    DOT = 52
    SLASH = 53
    RIGHTSHIFT = 54
    KPASTERISK = 55
    LEFTALT = 56
    SPACE = 57
    CAPSLOCK = 58
    F1 = 59
    F2 = 60
    F3 = 61
    F4 = 62
    F5 = 63
    F6 = 64
    F7 = 65
    F8 = 66
    F9 = 67
    F10 = 68
    NUMLOCK = 69
    SCROLLLOCK = 70
    KP7 = 71
    KP8 = 72
    KP9 = 73
    KPMINUS = 74
    KP4 = 75
    KP5 = 76
    KP6 = 77
    KPPLUS = 78
    KP1 = 79
    KP2 = 80
    KP3 = 81
    KP0 = 82
    KPDOT = 83

    F11 = 87
    F12 = 88
    RO = 89
    KPJPCOMMA = 95
    KPENTER = 96
    RIGHTCTRL = 97
    KPSLASH = 98
    SYSRQ = 99
    RIGHTALT = 100
    LINEFEED = 101
    HOME = 102
    UP = 103
    PAGEUP = 104
    LEFT = 105
    RIGHT = 106
    END = 107
    DOWN = 108
    PAGEDOWN = 109
    INSERT = 110
    DELETE = 111
    MACRO = 112
    MUTE = 113
    VOLUMEDOWN = 114
    VOLUMEUP = 115
    POWER = 116
    KPEQUAL = 117
    KPPLUSMINUS = 118
    PAUSE = 119
    SCALE = 120

    KPCOMMA = 121
    HANGEUL = 122
    HANGUEL = HANGEUL
    HANJA = 123
    YEN = 124
    LEFTMETA = 125
    RIGHTMETA = 126
    COMPOSE = 127

    STOP = 128
    AGAIN = 129
    PROPS = 130
    UNDO = 131
    FRONT = 132
    COPY = 133
    OPEN = 134
    PASTE = 135
    FIND = 136
    CUT = 137
    HELP = 138
    MENU = 139
    CALC = 140
    SETUP = 141
    SLEEP = 142
    WAKEUP = 143
    FILE = 144
    SENDFILE = 145
    DELETEFILE = 146
    XFER = 147
    PROG1 = 148
    PROG2 = 149
    WWW = 150
    MSDOS = 151
    COFFEE = 152
    SCREENLOCK = COFFEE
    ROTATE_DISPLAY = 153
    DIRECTION = ROTATE_DISPLAY
    CYCLEWINDOWS = 154
    MAIL = 155
    BOOKMARKS = 156
    COMPUTER = 157
    BACK = 158
    FORWARD = 159
    CLOSECD = 160
    EJECTCD = 161
    EJECTCLOSECD = 162
    NEXTSONG = 163
    PLAYPAUSE = 164
    PREVIOUSSONG = 165
    STOPCD = 166
    RECORD = 167
    REWIND = 168
    PHONE = 169
    ISO = 170
    CONFIG = 171
    HOMEPAGE = 172
    REFRESH = 173
    EXIT = 174
    MOVE = 175
    EDIT = 176
    SCROLLUP = 177
    SCROLLDOWN = 178
    KPLEFTPAREN = 179
    KPRIGHTPAREN = 180
    NEW = 181
    REDO = 182

    F13 = 183
    F14 = 184
    F15 = 185
    F16 = 186
    F17 = 187
    F18 = 188
    F19 = 189
    F20 = 190
    F21 = 191
    F22 = 192
    F23 = 193
    F24 = 194

    PLAYCD = 200
    PAUSECD = 201
    PROG3 = 202
    PROG4 = 203
    ALL_APPLICATIONS = 204
    DASHBOARD = ALL_APPLICATIONS
    SUSPEND = 205
    CLOSE = 206
    PLAY = 207
    FASTFORWARD = 208
    BASSBOOST = 209
    PRINT = 210
    HP = 211
    CAMERA = 212
    SOUND = 213
    QUESTION = 214
    EMAIL = 215
    CHAT = 216
    SEARCH = 217
    CONNECT = 218
    FINANCE = 219
    SPORT = 220
    SHOP = 221
    ALTERASE = 222
    CANCEL = 223
    BRIGHTNESSDOWN = 224
    BRIGHTNESSUP = 225
    MEDIA = 226

    SWITCHVIDEOMODE = 227
    KBDILLUMTOGGLE = 228
    KBDILLUMDOWN = 229
    KBDILLUMUP = 230

    SEND = 231
    REPLY = 232
    FORWARDMAIL = 233
    SAVE = 234
    DOCUMENTS = 235

    BATTERY = 236

    BLUETOOTH = 237
    WLAN = 238
    UWB = 239

    UNKNOWN = 240

    VIDEO_NEXT = 241
    VIDEO_PREV = 242
    BRIGHTNESS_CYCLE = 243
    BRIGHTNESS_AUTO = 244
    BRIGHTNESS_ZERO = BRIGHTNESS_AUTO
    DISPLAY_OFF = 245

    WWAN = 246
    WIMAX = WWAN
    RFKILL = 247

    MICMUTE = 248


async def main():
    debug: bool = os.getenv("INPUT_DEBUG", "false").lower() != "false"

    print(f"Debug: {'true' if debug else 'false'}")

    device_name = "AT Translated Set 2 keyboard"

    try:
        device_name = sys.argv[1]
    except IndexError:
        pass

    idev: evdev.InputDevice | None = None

    devices = [evdev.InputDevice(path) for path in evdev.list_devices()]

    for device in devices:
        if device.name == device_name:
            print(device.path, device.name, device.phys)
            idev = device
            break

    if idev is None:
        print("No device found")
        return

    # Copy all capabilities from the original device
    all_capabilities = defaultdict(set)
    for ev_type, ev_codes in idev.capabilities().items():
        all_capabilities[ev_type].update(ev_codes)

    # Add scroll capailities
    all_capabilities[Event.REL].add(Rel.MOUSEX)
    all_capabilities[Event.REL].add(Rel.MOUSEY)
    all_capabilities[Event.REL].add(Rel.SCROLLX)
    all_capabilities[Event.REL].add(Rel.SCROLLY)

    del all_capabilities[Event.SYN]

    udev = evdev.UInput(events=all_capabilities, name="pykbd")
    odev = evdev.InputDevice(udev.device.path)  # type: ignore

    print(udev.capabilities(verbose=True).keys())
    print(udev.phys)
    print(udev.device)

    Path("/dev/input/pykbd").unlink(missing_ok=True)
    Path("/dev/input/pykbd").symlink_to(udev.device.path, False)  # type: ignore

    caps_esc_threshold = 0.5

    keys_state = {}

    def in_key_active(key: Keys) -> bool:
        return any(e == key for e in idev.active_keys())

    def out_key_active(key: Keys) -> bool:
        return any(e == key for e in odev.active_keys())

    def update_key_state(event: evdev.InputEvent):
        if keys_state.get(event.code) is None:
            keys_state[event.code] = {
                State.VALUE: event.value,
                State.DOWNTIME: time.time(),
                State.HOLDTIME: time.time(),
                State.UPTIME: time.time(),
                State.HOLDCOUNT: 0,
            }

        key_state = keys_state[event.code]

        key_state[State.VALUE] = event.value
        if event.value == Action.DOWN:
            key_state[State.DOWNTIME] = time.time()
        elif event.value == Action.HOLD:
            key_state[State.HOLDTIME] = time.time()
            key_state[State.HOLDCOUNT] += 1
        elif event.value == Action.UP:
            key_state[State.UPTIME] = time.time()
            key_state[State.HOLDCOUNT] = 0

        keys_state[event.code] = key_state
        return key_state

    def can_up(etype, code, value):
        if value != Action.UP:
            return True
        return etype == Event.KEY and value == Action.UP and out_key_active(code)

    def write_event(event: evdev.InputEvent):
        if not can_up(event.type, event.code, event.value):
            return False
        udev.write_event(event)
        if debug:
            print(f"Outputting: {evdev.categorize(event)}")
        return True

    def write(etype, code, value):
        if not can_up(etype, code, value):
            return False
        udev.write(etype, code, value)
        if debug:
            event = evdev.InputEvent(0, 0, etype, code, value)
            print(f"Outputting: {evdev.categorize(event)}")
        return True

    def press(code):
        write(Event.KEY, code, Action.DOWN)

    def release(code):
        write(Event.KEY, code, Action.UP)

    def bounce(code):
        press(code)
        release(code)

    while len(idev.active_keys()) > 0:
        print("There are currently active keys, please release them before continuing")
        print(f"Active input keys: {idev.active_keys(verbose=True)}")
        time.sleep(1)

    idev.repeat = (250, 33)
    print("Repeat settings: {}\n".format(idev.repeat))

    # Grab the device to prevent other processes from reading it
    with idev.grab_context():
        event: evdev.InputEvent
        async for event in idev.async_read_loop():
            start_time = time.time()
            udev.syn()
            if event.type == Event.KEY:
                if in_key_active(Keys.ESC) and in_key_active(Keys.END):
                    # ESC + END to exit, will ungrab since we're in a context manager
                    for id in odev.active_keys():
                        release(id)

                    return

                if in_key_active(Keys.ESC) and in_key_active(Keys.INSERT):
                    print(f"Input active keys: {idev.active_keys(verbose=True)}")
                    print(f"Output active keys: {odev.active_keys(verbose=True)}")
                    continue

                key_state = update_key_state(event)

                # if debug and (
                #    event.value != Action.HOLD or key_state[State.HOLDCOUNT] == 1
                # ):
                if debug:
                    print(evdev.categorize(event))
                    print(f"Input active keys: {idev.active_keys(verbose=True)}")
                    print(f"Output active keys: {odev.active_keys(verbose=True)}")

                if True:  # add layers when we feel like it
                    # Send CTRL if CAPSLOCK is pressed
                    # Send ESC if CAPSLOCK is released within caps_esc_threshold
                    if event.code == Keys.CAPSLOCK:
                        event.code = Keys.LEFTCTRL
                        write_event(event)

                        if event.value == Action.UP:
                            if (
                                time.time() - key_state[State.DOWNTIME]
                                < caps_esc_threshold
                            ):
                                bounce(Keys.ESC)

                        continue

                    # Send capslock if CAPS + ESC is pressed
                    elif (
                        event.code == Keys.ESC
                        and event.value == Action.DOWN
                        and in_key_active(Keys.CAPSLOCK)
                    ):
                        bounce(Keys.CAPSLOCK)

                        continue

                    # Allow scrolling with capslock + hjkl
                    elif in_key_active(Keys.CAPSLOCK):
                        distance = 1
                        mouse_event = (None, None)

                        if in_key_active(Keys.SPACE):
                            distance = key_state[State.HOLDCOUNT]


                        if not in_key_active(Keys.SPACE):
                            if event.code == Keys.H:
                                mouse_event = (Rel.SCROLLX, -distance)
                            elif event.code == Keys.J:
                                mouse_event = (Rel.SCROLLY, -distance)
                            elif event.code == Keys.K:
                                mouse_event = (Rel.SCROLLY, distance)
                            elif event.code == Keys.L:
                                mouse_event = (Rel.SCROLLX, distance)
                        else:
                            if event.code == Keys.H:
                                mouse_event = (Rel.MOUSEX, -distance)
                            elif event.code == Keys.J:
                                mouse_event = (Rel.MOUSEY, distance)
                            elif event.code == Keys.K:
                                mouse_event = (Rel.MOUSEY, -distance)
                            elif event.code == Keys.L:
                                mouse_event = (Rel.MOUSEX, distance)

                        if mouse_event != (None, None):
                            # If we're not holding down input ctrl, release the output ctrl
                            # else we'll be zooming in web browsers and such.
                            if not in_key_active(Keys.LEFTCTRL):
                                release(Keys.LEFTCTRL)
                            if not in_key_active(Keys.RIGHTCTRL):
                                release(Keys.RIGHTCTRL)
                            write(Event.REL, mouse_event[0], mouse_event[1])
                            continue
                        if event.code == Keys.SPACE:
                            continue

                    # Map ALT (left or right) + åäö ( ['; ) to åäö
                    elif in_key_active(Keys.RIGHTALT) or in_key_active(Keys.LEFTALT):
                        code = None

                        if event.code == Keys.LEFTBRACE:
                            code = Keys.W
                        elif event.code == Keys.APOSTROPHE:
                            code = Keys.A
                        elif event.code == Keys.SEMICOLON:
                            code = Keys.O

                        if code is not None:
                            event.code = code
                            release(Keys.LEFTALT)
                            press(Keys.RIGHTALT)
                            write_event(event)
                            release(Keys.RIGHTALT)
                            continue

                    # Map CTRL + SHIFT + hjkl to arrow keys
                    elif in_key_active(Keys.LEFTCTRL) and in_key_active(Keys.LEFTSHIFT):
                        code = None

                        if event.code == Keys.H:
                            code = Keys.LEFT
                        elif event.code == Keys.J:
                            code = Keys.DOWN
                        elif event.code == Keys.K:
                            code = Keys.UP
                        elif event.code == Keys.L:
                            code = Keys.RIGHT

                        if code is not None:
                            event.code = code
                            release(Keys.LEFTCTRL)
                            release(Keys.LEFTSHIFT)
                            write_event(event)
                            continue

                if len(idev.active_keys()) == 0 and len(odev.active_keys()) > 0:
                    for id in odev.active_keys():
                        if id != event.code:
                            print(
                                f"Releasing {id} because input is empty, you probably have a stateful bug"
                            )
                            print(evdev.categorize(event))
                            print(
                                f"Input active keys: {idev.active_keys(verbose=True)}"
                            )
                            print(
                                f"Output active keys: {odev.active_keys(verbose=True)}"
                            )
                            release(id)

                if debug:
                    print(f"Time to process event: {time.time() - start_time}")

            # Pass any events we haven't handled to the virtual device
            write_event(event)


if __name__ == "__main__":
    asyncio.run(main())
