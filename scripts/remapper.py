#! /usr/bin/env python3

import asyncio
import evdev
import grp
import json
import os
import sys
import time
import sh
import libvirt

from evdev import util
from collections import defaultdict
from datetime import datetime
from enum import IntEnum, auto
from pathlib import Path
from sh import ddcutil, virsh  # type: ignore
from signal import SIGINT, SIGTERM

pyprint = print

headset_xml_path = os.environ.get("HEADSET_XML_PATH") or "./resources/logitech-g933.xml"
gaming_mode: bool = False

outevents = None
macroevents = None
inputevents = None
main_task = None
macropad_attach: bool = True


async def ddcutil_getvcp():
    for line in (
        await ddcutil("--model=XWU-CBA", "getvcp", "0x60", "--brief", _async=True)
    ).splitlines():
        if line.startswith("VCP"):
            return line


async def ddcutil_hdmi():
    print("Setting input to HDMI")
    print(await ddcutil("--model=XWU-CBA", "setvcp", "0x60", "0x11", _async=True))


async def ddcutil_dp():
    print("Setting input to DP")
    print(await ddcutil("--model=XWU-CBA", "setvcp", "0x60", "0x0f", _async=True))


def dtime():
    return datetime.now().strftime("%H:%M:%S.%f")


def print(*args, **kwargs):
    if "SYSTEMD_EXEC_PID" in os.environ.keys():
        pyprint(*args, **kwargs, flush=True)
    else:
        pyprint(dtime(), *args, **kwargs)


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
    debug: bool = os.getenv("INPUT_DEBUG", "false") in ["true", "yes", "1"]
    device_name: str = os.getenv("INPUT_NAME", "")
    hostname: str = os.getenv("hostname", "")

    print(f"Debug: {'true' if debug else 'false'}")
    print(f"Keyboard name: {device_name} (Case sensitive)")

    try:
        device_name = sys.argv[1]
    except IndexError:
        pass

    idev: evdev.InputDevice | None = None

    def get_input_device(name: str, verbose: bool = True):
        devices = [evdev.InputDevice(path) for path in evdev.list_devices()]
        for device in devices:
            if device.name == name:
                if verbose:
                    print(f"Found device: {device}")
                # print(f"Leds: {device.leds(verbose=True)}")
                # print(f"Capabilities: {device.capabilities(verbose=True)}")
                return device

        if verbose:
            print(f"Device {name} not found")
            print("Available devices:")

            for device in devices:
                print(device)

        return None

    idev = get_input_device(device_name, verbose=False)
    if idev is None:
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

    print(f"Created device: {udev}")
    print(udev.capabilities(verbose=True).keys())

    Path("/dev/input/pykbd").unlink(missing_ok=True)
    Path("/dev/input/pykbd").symlink_to(udev.device.path, False)  # type: ignore

    caps_esc_threshold = 0.5

    keys_state = {}

    def in_key_active(key: Keys) -> bool:
        return any(e == key for e in idev.active_keys())

    def out_key_active(key: Keys) -> bool:
        return any(e == key for e in odev.active_keys())

    def in_key_doubleclick(code) -> bool:
        key_state = keys_state[code]

        if time.time() - key_state[State.UPTIME] < 0.5:
            return True

        return False

    def update_key_state(event: evdev.InputEvent):
        if keys_state.get(event.code) is None:
            itime = time.time() - 60
            keys_state[event.code] = {
                State.VALUE: event.value,
                State.DOWNTIME: itime,
                State.HOLDTIME: itime,
                State.UPTIME: itime,
                State.HOLDCOUNT: 0,
            }

        key_state = keys_state[event.code]

        key_state[State.VALUE] = event.value
        if event.value == Action.DOWN:
            key_state[State.DOWNTIME] = event.timestamp()
        elif event.value == Action.HOLD:
            key_state[State.HOLDTIME] = event.timestamp()
            key_state[State.HOLDCOUNT] += 1
        elif event.value == Action.UP:
            key_state[State.UPTIME] = event.timestamp()
            key_state[State.HOLDCOUNT] = 0

        keys_state[event.code] = key_state
        return key_state

    def can_up(etype, code, value):
        if value != Action.UP:
            return True
        return etype == Event.KEY and value == Action.UP and out_key_active(code)

    def write_event(event: evdev.InputEvent, syn: bool = True):
        if not can_up(event.type, event.code, event.value):
            return False
        udev.write_event(event)
        if syn:
            udev.syn()
        if debug:
            print(f"Outputting: {evdev.categorize(event)}")
        return True

    def write(etype, code, value):
        return write_event(evdev.InputEvent(0, 0, etype, code, value))

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

    class RemapperProtocol(asyncio.Protocol):
        transport: asyncio.Transport

        def __init__(self, config):
            self.wminfo = config

        def write_data(self, data: str):
            self.transport.write(data.encode())

        def connection_made(self, transport):
            self.transport = transport  # type: ignore
            print("Connection established")
            self.write_data("YOYO")

        def data_received(self, data):
            message = data.decode()
            print(f"Received message: {message}")
            # Can't set self.wminfo directly, it's a reference to the original dict
            for k, v in json.loads(message).items():
                self.wminfo[k] = v
            self.write_data(message)
            print("Echoed back")

        def connection_lost(self, exc):
            print("Connection lost")
            exit(-1)

    wminfo = {
        "windowClass": "unset",
        "windowTitle": "unset",
    }

    sockpath = "/tmp/pykbd.sock"
    loop = asyncio.get_event_loop()
    await loop.create_unix_server(lambda: RemapperProtocol(wminfo), path=sockpath)
    os.chown(sockpath, 1, grp.getgrnam("uinput").gr_gid)
    os.chmod(sockpath, 0o660)

    # Check if we've forgot to release any keys when events are coming back in on our virtual device
    async def handle_output_events():
        async for _ in odev.async_read_loop():
            in_active_keys = idev.active_keys()
            out_active_keys = odev.active_keys()
            if len(in_active_keys) == 0 and len(out_active_keys) > 0:
                for id in out_active_keys:
                    print(f"Releasing key {id} because input is empty")
                    print(f"Output active keys: {odev.active_keys(verbose=True)}")
                    release(id)

    async def handle_macropad_input_events():
        global macropad_attach
        global inputevents

        mdev = get_input_device("IDOBAO ID3KEY")
        if mdev is None:
            return

        with mdev.grab_context():
            print("Grabbing macropad")
            event: evdev.InputEvent

            last_key_up_code = Keys.F24
            last_key_up_time = time.time()

            ddctask = None
            usb_xtach_task = None

            async for event in mdev.async_read_loop():
                base_path = "/home/lillecarl/Code/nixos/resources"

                if event.type != Event.KEY:
                    continue

                if event.value == Action.HOLD:
                    continue

                if event.value != Action.UP:
                    continue

                print(f"event: {util.categorize(event)}")
                print(f"Macropad active keys: {mdev.active_keys(verbose=True)}")
                print(f"last_key_up_code: {last_key_up_code}, event.code: {event.code}")
                print(
                    f"last_key_up_time: {last_key_up_time} diff: {time.time() - last_key_up_time}"
                )

                if (
                    True
                    and any(e == Keys.LEFTCTRL for e in mdev.active_keys())
                    and event.code == Keys.C
                    and last_key_up_code == Keys.C
                    and time.time() - last_key_up_time < 0.5
                ):
                    if macropad_attach:
                        print("Attaching devices")

                        async def attach():
                            await attach_device(f"{base_path}/daskeyboard.xml")
                            await attach_device(f"{base_path}/steelseries-sensei.xml")
                            await attach_device(f"{base_path}/glorious-mouse.xml")
                            await attach_device(f"{base_path}/8bitdo.xml")
                        if usb_xtach_task is None or usb_xtach_task.done():
                            usb_xtach_task = loop.create_task(attach())
                        macropad_attach = False
                    else:
                        print("Detaching devices")

                        async def detach():
                            await detach_device(f"{base_path}/daskeyboard.xml")
                            await detach_device(f"{base_path}/steelseries-sensei.xml")
                            await detach_device(f"{base_path}/glorious-mouse.xml")
                            await detach_device(f"{base_path}/8bitdo.xml")
                        if usb_xtach_task is None or usb_xtach_task.done():
                            usb_xtach_task = loop.create_task(detach())
                        macropad_attach = True
                elif (
                    True
                    and any(e == Keys.LEFTCTRL for e in mdev.active_keys())
                    and event.code == Keys.V
                    and last_key_up_code == Keys.V
                    and time.time() - last_key_up_time < 0.5
                ):
                    if ddctask is None or ddctask.done():
                        ddctask = loop.create_task(ddc_switch())
                elif (
                    True
                    and any(e == Keys.V for e in mdev.active_keys())
                    and event.code == Keys.LEFTCTRL
                    and last_key_up_code == Keys.LEFTCTRL
                    and time.time() - last_key_up_time < 0.5
                ):
                    cancel_all()
                elif (
                    True
                    and any(e == Keys.V for e in mdev.active_keys())
                    and event.code == Keys.C
                    and last_key_up_code == Keys.C
                    and time.time() - last_key_up_time < 0.5
                ):
                    if inputevents is not None:
                        print("Stopping inputevents")
                        inputevents.cancel()
                    print("Starting inputevents")
                    inputevents = loop.create_task(handle_input_events())

                last_key_up_code = event.code
                last_key_up_time = time.time()

    class VirshAction(IntEnum):
        ATTACH = auto()
        DETACH = auto()

    async def _virsh_set_device(vm: str, xml_path: str, action: VirshAction):
        actionstr = "attach-device" if action == VirshAction.ATTACH else "detach-device"
        try:
            await virsh(actionstr, vm, xml_path, "--live", _async=True)
            print(f"{actionstr} {xml_path} to {vm}")
        except sh.ErrorReturnCode as e:
            print(f"Failed to {actionstr} {xml_path} to {vm}")
            print(e.stderr.decode())

    async def attach_device(xml_path: str):
        await _virsh_set_device("win11-4", xml_path, VirshAction.ATTACH)

    async def detach_device(xml_path: str):
        await _virsh_set_device("win11-4", xml_path, VirshAction.DETACH)

    async def ddc_switch():
        ddcutil_current = str(await ddcutil_getvcp())
        print(f"vcp: {ddcutil_current}")
        if "VCP 60 SNC x00" in ddcutil_current:
            await ddcutil_dp()
        elif "VCP 60 SNC x0f" in ddcutil_current:
            await ddcutil_hdmi()

    async def handle_input_events():
        global gaming_mode
        idev = get_input_device(device_name, verbose=False)
        if idev is None:
            return

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

                        cancel_all()

                    key_state = update_key_state(event)

                    if debug and (
                        event.value != Action.HOLD or key_state[State.HOLDCOUNT] == 1
                    ):
                        print(evdev.categorize(event))
                        print(f"Input active keys: {idev.active_keys(verbose=True)}")
                        print(f"Output active keys: {odev.active_keys(verbose=True)}")
                        print(f"Active window name: {wminfo['windowTitle']}")

                    # Double click scroll lock to switch display input. While holding left meta, toggle gaming mode
                    if (
                        event.code == Keys.SCROLLLOCK
                        and event.value == Action.DOWN
                        and time.time() - key_state[State.UPTIME] < 0.5
                    ):
                        if in_key_active(Keys.LEFTMETA):
                            gaming_mode = not gaming_mode
                            print(f"Gaming mode: {'on' if gaming_mode else 'off'}")
                        elif in_key_active(Keys.N1):
                            pass  # Switch input of left BENQ display
                        elif in_key_active(Keys.N2):
                            pass  # Switch input of right BENQ display
                        elif in_key_active(Keys.LEFTCTRL):
                            press(Keys.RIGHTSHIFT)
                        elif in_key_active(Keys.LEFTALT):
                            vm = "win11-4"
                            try:
                                await virsh(
                                    "detach-device",
                                    vm,
                                    headset_xml_path,
                                    "--live",
                                    _async=True,
                                )

                                print(f"Detached {headset_xml_path} from {vm}")
                                print("Waiting 5 seconds before attaching")
                                await asyncio.sleep(5)
                            except sh.ErrorReturnCode as e:
                                print(f"Failed to detach {headset_xml_path} to {vm}")
                                print(e.stderr.decode())

                            try:
                                await virsh(
                                    "attach-device",
                                    vm,
                                    headset_xml_path,
                                    "--live",
                                    _async=True,
                                )
                                print(f"Attached {headset_xml_path} to {vm}")
                            except sh.ErrorReturnCode as e:
                                print(f"Failed to attach {headset_xml_path} to {vm}")
                                print(e.stderr.decode())
                        else:
                            asyncio.create_task(ddc_switch())

                        continue

                    if gaming_mode:
                        write_event(event)
                        continue
                    else:
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
                        elif in_key_active(Keys.RIGHTALT) or in_key_active(
                            Keys.LEFTALT
                        ):
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

                    if debug:
                        print(f"Time to process event: {time.time() - start_time}")

                # Pass any events we haven't handled to the virtual device
                write_event(event)

    global outevents
    global macroevents
    global inputevents
    loop = asyncio.get_event_loop()
    # Handle output events in a separate task
    outevents = loop.create_task(handle_output_events())
    macroevents = loop.create_task(handle_macropad_input_events())
    inputevents = loop.create_task(handle_input_events())

    while True:
        await asyncio.sleep(1)


def cancel_all():
    if outevents is not None:
        outevents.cancel()
    if macroevents is not None:
        macroevents.cancel()
    if inputevents is not None:
        inputevents.cancel()
    if main_task is not None:
        main_task.cancel()


if __name__ == "__main__":
    loop = asyncio.get_event_loop()
    main_task = asyncio.ensure_future(main())
    if main_task is None:
        exit(0)
    for signal in [SIGINT, SIGTERM]:
        loop.add_signal_handler(signal, cancel_all)
    try:
        loop.run_until_complete(main_task)
    except asyncio.CancelledError:
        print("Cancelled")
    finally:
        loop.close()
