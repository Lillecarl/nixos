{ config
, pkgs
, ...
}:
let
  # machinectl gives us a shell to run a command as a user with dbus and everything set up by systemd
  mctl_shell_qdbus = "${pkgs.systemd}/bin/machinectl shell lillecarl@ /run/current-system/sw/bin/qdbus";
  # invokeShortcut runs qdbus to invoke a KDE shortcut (see settings page)
  invokeShortcut = shortcut: "${mctl_shell_qdbus} org.kde.kglobalaccel /component/kwin org.kde.kglobalaccel.Component.invokeShortcut \"${shortcut}\" &";
  # invokeCommand runs machinectl, sets up a temporary systemd unit, steals the environment variables from plasmashell and executes a command
  invokeCommand = command: "${pkgs.systemd}/bin/machinectl shell lillecarl@ ${pkgs.systemd}/bin/systemd-run --user ${envstealer}/bin/envstealer plasmashell ${command} &";
  # Attributes used for keydown registration
  keyAttributes = [ "ungrabbed" "exec" "grab" ];
  # Attributes used for releasing
  releaseAttributes = [ "grabbed" "noexec" "ungrab" "rcvrel" "allrel" ];

  # https://raw.githubusercontent.com/torvalds/linux/master/include/uapi/linux/input-event-codes.h
  KEY_RESERVED = 0;
  KEY_ESC = 1;
  KEY_1 = 2;
  KEY_2 = 3;
  KEY_3 = 4;
  KEY_4 = 5;
  KEY_5 = 6;
  KEY_6 = 7;
  KEY_7 = 8;
  KEY_8 = 9;
  KEY_9 = 10;
  KEY_0 = 11;
  KEY_MINUS = 12;
  KEY_EQUAL = 13;
  KEY_BACKSPACE = 14;
  KEY_TAB = 15;
  KEY_Q = 16;
  KEY_W = 17;
  KEY_E = 18;
  KEY_R = 19;
  KEY_T = 20;
  KEY_Y = 21;
  KEY_U = 22;
  KEY_I = 23;
  KEY_O = 24;
  KEY_P = 25;
  KEY_LEFTBRACE = 26;
  KEY_RIGHTBRACE = 27;
  KEY_ENTER = 28;
  KEY_LEFTCTRL = 29;
  KEY_A = 30;
  KEY_S = 31;
  KEY_D = 32;
  KEY_F = 33;
  KEY_G = 34;
  KEY_H = 35;
  KEY_J = 36;
  KEY_K = 37;
  KEY_L = 38;
  KEY_SEMICOLON = 39;
  KEY_APOSTROPHE = 40;
  KEY_GRAVE = 41;
  KEY_LEFTSHIFT = 42;
  KEY_BACKSLASH = 43;
  KEY_Z = 44;
  KEY_X = 45;
  KEY_C = 46;
  KEY_V = 47;
  KEY_B = 48;
  KEY_N = 49;
  KEY_M = 50;
  KEY_COMMA = 51;
  KEY_DOT = 52;
  KEY_SLASH = 53;
  KEY_RIGHTSHIFT = 54;
  KEY_KPASTERISK = 55;
  KEY_LEFTALT = 56;
  KEY_SPACE = 57;
  KEY_CAPSLOCK = 58;
  KEY_F1 = 59;
  KEY_F2 = 60;
  KEY_F3 = 61;
  KEY_F4 = 62;
  KEY_F5 = 63;
  KEY_F6 = 64;
  KEY_F7 = 65;
  KEY_F8 = 66;
  KEY_F9 = 67;
  KEY_F10 = 68;
  KEY_NUMLOCK = 69;
  KEY_SCROLLLOCK = 70;
  KEY_KP7 = 71;
  KEY_KP8 = 72;
  KEY_KP9 = 73;
  KEY_KPMINUS = 74;
  KEY_KP4 = 75;
  KEY_KP5 = 76;
  KEY_KP6 = 77;
  KEY_KPPLUS = 78;
  KEY_KP1 = 79;
  KEY_KP2 = 80;
  KEY_KP3 = 81;
  KEY_KP0 = 82;
  KEY_KPDOT = 83;
  KEY_ZENKAKUHANKAKU = 85;
  KEY_102ND = 86;
  KEY_F11 = 87;
  KEY_F12 = 88;
  KEY_RO = 89;
  KEY_KATAKANA = 90;
  KEY_HIRAGANA = 91;
  KEY_HENKAN = 92;
  KEY_KATAKANAHIRAGANA = 93;
  KEY_MUHENKAN = 94;
  KEY_KPJPCOMMA = 95;
  KEY_KPENTER = 96;
  KEY_RIGHTCTRL = 97;
  KEY_KPSLASH = 98;
  KEY_SYSRQ = 99;
  KEY_PRINTSCREEN = 99; # Custom
  KEY_RIGHTALT = 100;
  KEY_LINEFEED = 101;
  KEY_HOME = 102;
  KEY_UP = 103;
  KEY_PAGEUP = 104;
  KEY_LEFT = 105;
  KEY_RIGHT = 106;
  KEY_END = 107;
  KEY_DOWN = 108;
  KEY_PAGEDOWN = 109;
  KEY_INSERT = 110;
  KEY_DELETE = 111;
  KEY_MACRO = 112;
  KEY_MUTE = 113;
  KEY_VOLUMEDOWN = 114;
  KEY_VOLUMEUP = 115;
  KEY_POWER = 116;
  KEY_KPEQUAL = 117;
  KEY_KPPLUSMINUS = 118;
  KEY_PAUSE = 119;
  KEY_SCALE = 120;
  KEY_KPCOMMA = 121;
  KEY_HANGEUL = 122;
  KEY_HANGUEL = KEY_HANGEUL;
  KEY_HANJA = 123;
  KEY_YEN = 124;
  KEY_LEFTMETA = 125;
  KEY_RIGHTMETA = 126;
  KEY_COMPOSE = 127;
  KEY_STOP = 128;
  KEY_AGAIN = 129;
  KEY_PROPS = 130;
  KEY_UNDO = 131;
  KEY_FRONT = 132;
  KEY_COPY = 133;
  KEY_OPEN = 134;
  KEY_PASTE = 135;
  KEY_FIND = 136;
  KEY_CUT = 137;
  KEY_HELP = 138;
  KEY_MENU = 139;
  KEY_CALC = 140;
  KEY_SETUP = 141;
  KEY_SLEEP = 142;
  KEY_WAKEUP = 143;
  KEY_FILE = 144;
  KEY_SENDFILE = 145;
  KEY_DELETEFILE = 146;
  KEY_XFER = 147;
  KEY_PROG1 = 148;
  KEY_PROG2 = 149;
  KEY_WWW = 150;
  KEY_MSDOS = 151;
  KEY_COFFEE = 152;
  KEY_SCREENLOCK = KEY_COFFEE;
  KEY_ROTATE_DISPLAY = 153;
  KEY_DIRECTION = KEY_ROTATE_DISPLAY;
  KEY_CYCLEWINDOWS = 154;
  KEY_MAIL = 155;
  KEY_BOOKMARKS = 156;
  KEY_COMPUTER = 157;
  KEY_BACK = 158;
  KEY_FORWARD = 159;
  KEY_CLOSECD = 160;
  KEY_EJECTCD = 161;
  KEY_EJECTCLOSECD = 162;
  KEY_NEXTSONG = 163;
  KEY_PLAYPAUSE = 164;
  KEY_PREVIOUSSONG = 165;
  KEY_STOPCD = 166;
  KEY_RECORD = 167;
  KEY_REWIND = 168;
  KEY_PHONE = 169;
  KEY_ISO = 170;
  KEY_CONFIG = 171;
  KEY_HOMEPAGE = 172;
  KEY_REFRESH = 173;
  KEY_EXIT = 174;
  KEY_MOVE = 175;
  KEY_EDIT = 176;
  KEY_SCROLLUP = 177;
  KEY_SCROLLDOWN = 178;
  KEY_KPLEFTPAREN = 179;
  KEY_KPRIGHTPAREN = 180;
  KEY_NEW = 181;
  KEY_REDO = 182;
  KEY_F13 = 183;
  KEY_F14 = 184;
  KEY_F15 = 185;
  KEY_F16 = 186;
  KEY_F17 = 187;
  KEY_F18 = 188;
  KEY_F19 = 189;
  KEY_F20 = 190;
  KEY_F21 = 191;
  KEY_F22 = 192;
  KEY_F23 = 193;
  KEY_F24 = 194;
  KEY_PLAYCD = 200;
  KEY_PAUSECD = 201;
  KEY_PROG3 = 202;
  KEY_PROG4 = 203;
  KEY_ALL_APPLICATIONS = 204;
  KEY_DASHBOARD = KEY_ALL_APPLICATIONS;
  KEY_SUSPEND = 205;
  KEY_CLOSE = 206;
  KEY_PLAY = 207;
  KEY_FASTFORWARD = 208;
  KEY_BASSBOOST = 209;
  KEY_PRINT = 210;
  KEY_HP = 211;
  KEY_CAMERA = 212;
  KEY_SOUND = 213;
  KEY_QUESTION = 214;
  KEY_EMAIL = 215;
  KEY_CHAT = 216;
  KEY_SEARCH = 217;
  KEY_CONNECT = 218;
  KEY_FINANCE = 219;
  KEY_SPORT = 220;
  KEY_SHOP = 221;
  KEY_ALTERASE = 222;
  KEY_CANCEL = 223;
  KEY_BRIGHTNESSDOWN = 224;
  KEY_BRIGHTNESSUP = 225;
  KEY_MEDIA = 226;
  KEY_SWITCHVIDEOMODE = 227;
  KEY_KBDILLUMTOGGLE = 228;
  KEY_KBDILLUMDOWN = 229;
  KEY_KBDILLUMUP = 230;
  KEY_SEND = 231;
  KEY_REPLY = 232;
  KEY_FORWARDMAIL = 233;
  KEY_SAVE = 234;
  KEY_DOCUMENTS = 235;
  KEY_BATTERY = 236;
  KEY_BLUETOOTH = 237;
  KEY_WLAN = 238;
  KEY_UWB = 239;
  KEY_UNKNOWN = 240;
  KEY_VIDEO_NEXT = 241;
  KEY_VIDEO_PREV = 242;
  KEY_BRIGHTNESS_CYCLE = 243;
  KEY_BRIGHTNESS_AUTO = 244;
  KEY_BRIGHTNESS_ZERO = KEY_BRIGHTNESS_AUTO;
  KEY_DISPLAY_OFF = 245;
  KEY_WWAN = 246;
  KEY_WIMAX = KEY_WWAN;
  KEY_RFKILL = 247;
  KEY_MICMUTE = 248;

  envstealer = pkgs.writeTextFile {
    name = "envstealer";
    text = ''
      #! /usr/bin/env xonsh

      import sys
      import os
      import psutil
      import subprocess

      print(sys.argv)

      def envsteal(pid: int):
        envfile = open("/proc/{}/environ".format(pid))
        envstr = envfile.read()
        envrows = envstr.split("\x00")
        for i in envrows:
          try:
            env = i.split("=", 1)
            ''${env[0]} = env[1] if env[1] is not None else ""
          except:
            pass

      def findproc(name: str):
        username = os.getlogin()
        print(username)
        pid = 0

        for proc in psutil.process_iter(['pid', 'name', 'username']):
          if proc.info['username'] == username and proc.info['name'].find(sys.argv[1]) >= 0 :
            print(proc.info['name'])
            pid = proc.info['pid']
            break

        return pid

      if __name__ == "__main__":
        pid = findproc(sys.argv[1])

        print(pid)

        if pid:
          envsteal(pid)
          @(sys.argv[2])

    '';
    executable = true;
    destination = "/bin/envstealer";
  };
in
rec
{
  services.actkbd = {
    enable = false;

    bindings = [
      {
        keys = [ KEY_LEFTMETA KEY_TAB ];
        events = [ "key" ];
        command = "${mctl_shell_qdbus} org.kde.krunner /App org.kde.krunner.App.query \"window: \" &";
        attributes = keyAttributes;
      }
      {
        keys = [ KEY_LEFTMETA KEY_TAB ];
        events = [ "rel" ];
        attributes = releaseAttributes;
      }
      {
        keys = [ KEY_SPACE KEY_LEFTALT ];
        events = [ "key" ];
        command = "${mctl_shell_qdbus} org.kde.krunner /App org.kde.krunner.App.query \"\" &";
        attributes = keyAttributes;
      }
      {
        keys = [ KEY_SPACE KEY_LEFTALT ];
        events = [ "rel" ];
        attributes = releaseAttributes;
      }
      {
        keys = [ KEY_LEFT KEY_LEFTMETA ];
        events = [ "key" ];
        command = invokeShortcut "Window Quick Tile Left";
        attributes = keyAttributes;
      }
      {
        keys = [ KEY_LEFT KEY_LEFTMETA ];
        events = [ "rel" ];
        attributes = releaseAttributes;
      }
      {
        keys = [ KEY_RIGHT KEY_LEFTMETA ];
        events = [ "key" ];
        command = invokeShortcut "Window Quick Tile Right";
        attributes = keyAttributes;
      }
      {
        keys = [ KEY_RIGHT KEY_LEFTMETA ];
        events = [ "rel" ];
        attributes = releaseAttributes;
      }
      {
        keys = [ KEY_UP KEY_LEFTMETA ];
        events = [ "key" ];
        command = invokeShortcut "Window Quick Tile Top";
        attributes = keyAttributes;
      }
      {
        keys = [ KEY_UP KEY_LEFTMETA ];
        events = [ "rel" ];
        attributes = releaseAttributes;
      }
      {
        keys = [ KEY_DOWN KEY_LEFTMETA ];
        events = [ "key" ];
        command = invokeShortcut "Window Quick Tile Bottom";
        attributes = keyAttributes;
      }
      {
        keys = [ KEY_DOWN KEY_LEFTMETA ];
        events = [ "rel" ];
        attributes = releaseAttributes;
      }
      {
        keys = [ KEY_LEFT KEY_UP KEY_LEFTMETA ];
        events = [ "key" ];
        command = invokeShortcut "Window Quick Tile Top Left";
        attributes = keyAttributes;
      }
      {
        keys = [ KEY_LEFT KEY_UP KEY_LEFTMETA ];
        events = [ "rel" ];
        attributes = releaseAttributes;
      }
      {
        keys = [ KEY_RIGHT KEY_UP KEY_LEFTMETA ];
        events = [ "key" ];
        command = invokeShortcut "Window Quick Tile Top Right";
        attributes = keyAttributes;
      }
      {
        keys = [ KEY_RIGHT KEY_UP KEY_LEFTMETA ];
        events = [ "rel" ];
        attributes = releaseAttributes;
      }
      {
        keys = [ KEY_LEFT KEY_DOWN KEY_LEFTMETA ];
        events = [ "key" ];
        command = invokeShortcut "Window Quick Tile Bottom Left";
        attributes = keyAttributes;
      }
      {
        keys = [ KEY_LEFT KEY_DOWN KEY_LEFTMETA ];
        events = [ "rel" ];
        attributes = releaseAttributes;
      }
      {
        keys = [ KEY_RIGHT KEY_DOWN KEY_LEFTMETA ];
        events = [ "key" ];
        command = invokeShortcut "Window Quick Tile Bottom Right";
        attributes = keyAttributes;
      }
      {
        keys = [ KEY_RIGHT KEY_DOWN KEY_LEFTMETA ];
        events = [ "rel" ];
        attributes = releaseAttributes;
      }
      {
        keys = [ KEY_F KEY_LEFTMETA ];
        events = [ "key" ];
        command = invokeShortcut "Window Maximize";
        attributes = keyAttributes;
      }
      {
        keys = [ KEY_F KEY_LEFTMETA ];
        events = [ "rel" ];
        attributes = releaseAttributes;
      }
      {
        keys = [ KEY_LEFTCTRL KEY_C ];
        events = [ "key" ];
        command = invokeShortcut "Copy";
        attributes = keyAttributes;
      }
      {
        keys = [ KEY_LEFTCTRL KEY_C ];
        events = [ "rel" ];
        attributes = releaseAttributes;
      }
      {
        keys = [ KEY_LEFTCTRL KEY_X ];
        events = [ "key" ];
        command = invokeShortcut "Cut";
        attributes = keyAttributes;
      }
      {
        keys = [ KEY_LEFTCTRL KEY_X ];
        events = [ "rel" ];
        attributes = releaseAttributes;
      }
      {
        keys = [ KEY_LEFTCTRL KEY_V ];
        events = [ "key" ];
        command = invokeShortcut "Paste";
        attributes = keyAttributes;
      }
      {
        keys = [ KEY_LEFTCTRL KEY_V ];
        events = [ "rel" ];
        attributes = releaseAttributes;
      }
      {
        keys = [ KEY_PRINTSCREEN ];
        events = [ "key" ];
        command = invokeCommand "spectacle";
        attributes = keyAttributes;
      }
      {
        keys = [ KEY_PRINTSCREEN ];
        events = [ "rel" ];
        attributes = releaseAttributes;
      }
    ];
  };
}
