#! /usr/bin/env xonsh

# ---------------------------
# ALIAS FUNCTIONS
# ---------------------------

# tfswitch with preconfigured root
def _tfswitch(args, stdin=None):
  /usr/bin/env tfswitch -b $XDG_BIN_HOME/terraform @(args)

# Use pactl (hosted by pipewire) to configure bluetooth modes
def _blueprofile(args, stdin=None):
  profile = None

  card: str = $(pactl list cards short | grep bluez | awk '{print $1 }')

  if args[0] == "mic":
    profile = "headset-head-unit"
  elif args[0] == "music":
    profile = "a2dp-sink"

  if len(card) <= 0:
    print("Found no suitable bluetooth \"card\"")
    profile = None

  if profile:
    print("Switching profile")
    pactl set-card-profile @(card) @(profile)
    if profile == "headset-head-unit":
      pactl set-default-source $(pactl list sources short | rg bluez_input | awk '{ print $1 }') # Switch this when switching from bluetooth too

# ---------------------------
# ALIASES
# ---------------------------

# systemctl shortcut
aliases["sc"] = "systemctl"
# systemctl --user shortcut
aliases["scu"] = "systemctl --user"
# Better ls
aliases['ls'] = 'exa -lah'
# Better cat
aliases['cat'] = 'bat'
# Go to git root folder
aliases['grt'] = lambda: os.chdir($(git rev-parse --show-toplevel).strip())
# NeoVIM > VIM
aliases['vim'] = 'nvim'
# tfswitch with preconfigured root
aliases["tfswitch"] = _tfswitch
# Set bluetooth mode (choose)
aliases["blueprofile"] = _blueprofile
# Set bluetooth mode to enable mic
aliases["bluemic"] = lambda x: _blueprofile(args=["mic"])
# Set bluetooth mode to enable high quality sound
aliases["bluesound"] = lambda x: _blueprofile(args=["music"])

