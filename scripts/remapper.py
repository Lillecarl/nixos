#! /usr/bin/env python3

import evdev
import time
import asyncio
import os
import sys
from enum import IntEnum, Enum, auto


class Layer(Enum):
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
    DOWNTIME = 1
    HOLDTIME = 2
    UPTIME = 3
    VALUE = 4
    HOLDCOUNT = 5


class Event(IntEnum):
    SYN = 0
    KEY = 1
    MSC = 4
    LED = 17


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

    selected_device: evdev.InputDevice | None = None

    devices = [evdev.InputDevice(path) for path in evdev.list_devices()]

    for device in devices:
        if device.name == device_name:
            print(device.path, device.name, device.phys)
            selected_device = device
            break

    if selected_device is None:
        print("No device found")
        return

    ui = evdev.UInput.from_device(selected_device, name="pykbd")
    print(ui.capabilities(verbose=True).keys())
    print(ui.phys)

    caps_esc_threshold = 0.5

    keys_state = {}

    def key_active(key: Keys) -> bool:
        return any(e == key for e in selected_device.active_keys())

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

    layer: Layer = Layer.NORMAL

    # Grab the device to prevent other processes from reading it
    with selected_device.grab_context():
        event: evdev.InputEvent
        async for event in selected_device.async_read_loop():
            if event.type == Event.KEY:
                if key_active(Keys.ESC) and key_active(Keys.END):
                    # ESC + END to exit, will ungrab since we're in a context manager
                    return

                key_state = update_key_state(event)

                if debug and (
                    event.value != Action.HOLD or key_state[State.HOLDCOUNT] == 1
                ):
                    print(evdev.categorize(event))
                    print(selected_device.active_keys(verbose=True))


                if key_active(Keys.ESC) and key_active(Keys.N):
                    if layer == Layer.NORMAL:
                        layer = Layer.NUMPAD
                    elif layer == Layer.NUMPAD:
                        layer = Layer.NORMAL
                    print(f"Layer: {layer.name}")

                if layer == Layer.NORMAL:
                    # Send CTRL if CAPSLOCK is pressed
                    # Send ESC if CAPSLOCK is released within caps_esc_threshold
                    if event.code == Keys.CAPSLOCK:
                        event.code = Keys.LEFTCTRL
                        ui.write_event(event)
                        ui.syn()

                        if event.value == Action.UP:
                            if time.time() - key_state[State.DOWNTIME] < caps_esc_threshold:
                                ui.write(Event.KEY, Keys.ESC, Action.DOWN)
                                ui.write(Event.KEY, Keys.ESC, Action.UP)
                                ui.syn()

                        continue

                    # Send capslock if CAPS + ESC is pressed
                    elif (
                        event.code == Keys.ESC
                        and event.value == Action.DOWN
                        and key_active(Keys.CAPSLOCK)
                    ):
                        ui.write(Event.KEY, Keys.CAPSLOCK, Action.DOWN)
                        ui.write(Event.KEY, Keys.CAPSLOCK, Action.UP)
                        ui.syn()

                        continue

                    # Map ALT (left or right) + åäö ( ['; ) to åäö
                    elif (key_active(Keys.RIGHTALT) or key_active(Keys.LEFTALT)):
                        hit: bool = False
                        if event.code == Keys.LEFTBRACE:
                            event.code = Keys.W
                            hit = True
                        elif event.code == Keys.APOSTROPHE:
                            event.code = Keys.A
                            hit = True
                        elif event.code == Keys.SEMICOLON:
                            event.code = Keys.O
                            hit = True

                        if hit:
                            ui.write(Event.KEY, Keys.LEFTALT, Action.UP)
                            ui.write(Event.KEY, Keys.RIGHTALT, Action.DOWN)
                            ui.write_event(event)
                            ui.write(Event.KEY, Keys.RIGHTALT, Action.UP)
                            ui.syn()
                            continue

                    # Map CTRL + SHIFT + hjkl to arrow keys
                    elif (key_active(Keys.LEFTCTRL) and key_active(Keys.LEFTSHIFT)):
                        hit: bool = False
                        if event.code == Keys.H:
                            event.code = Keys.LEFT
                            hit = True
                        elif event.code == Keys.J:
                            event.code = Keys.DOWN
                            hit = True
                        elif event.code == Keys.K:
                            event.code = Keys.UP
                            hit = True
                        elif event.code == Keys.L:
                            event.code = Keys.RIGHT
                            hit = True

                        if hit:
                            ui.write(Event.KEY, Keys.LEFTCTRL, Action.UP)
                            ui.write(Event.KEY, Keys.LEFTSHIFT, Action.UP)
                            ui.write_event(event)
                            ui.syn()
                            continue

                # Numpad layer, map zxcasdqwe to 123456789
                elif layer == Layer.NUMPAD:
                    key = Keys(event.code)
                    if key == Keys.ESC and event.value == Action.DOWN:
                        layer = Layer.NORMAL
                        print(f"Layer: {layer.name}")
                        continue
                    if key == Keys.Q:
                        event.code = Keys.KP7
                    elif key == Keys.W:
                        event.code = Keys.KP8
                    elif key == Keys.E:
                        event.code = Keys.KP9
                    elif key == Keys.A:
                        event.code = Keys.KP4
                    elif key == Keys.S:
                        event.code = Keys.KP5
                    elif key == Keys.D:
                        event.code = Keys.KP6
                    elif key == Keys.Z:
                        event.code = Keys.KP1
                    elif key == Keys.X:
                        event.code = Keys.KP2
                    elif key == Keys.C:
                        event.code = Keys.KP3
                    elif key == Keys.GRAVE:
                        event.code = Keys.NUMLOCK

                    ui.write_event(event)
                    ui.syn()
                    continue


            # Pass any events we haven't handled to the virtual device
            ui.write_event(event)
            ui.syn()


if __name__ == "__main__":
    asyncio.run(main())
