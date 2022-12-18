#! /usr/bin/env xonsh

# ---------------------------
# ALIAS MIDDLE STORAGE
# This is used for aliases "aliasup" and "aliasdown" to enable and
# disable all custom aliases at one
# ---------------------------

carliases = dict()

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

def _aliasupdown(data, up):
  for k,v in data.items():
    try:
      if up:
        aliases[k] = v
      else:
        aliases.pop(k)
    except KeyError:
      pass
    except Exception as e:
      print("Couldn't remove {0}".format(k))
      print(e)

# ---------------------------
# ALIASES
# ---------------------------

# Semi-common cd typo
carliases['cd..'] = 'cd ..'
# systemctl shortcut
carliases["sc"] = "systemctl"
# systemctl --user shortcut
carliases["scu"] = "systemctl --user"
# Better ls
carliases['ls'] = 'exa -lah'
# Better cat
carliases['cat'] = 'bat'
# Go to git root folder
carliases['grt'] = lambda: os.chdir($(git rev-parse --show-toplevel).strip())
# NeoVIM > VIM
carliases['vim'] = 'nvim'
# tfswitch with preconfigured root
carliases["tfswitch"] = _tfswitch
# Set bluetooth mode (choose)
carliases["blueprofile"] = _blueprofile
# Set bluetooth mode to enable mic
carliases["bluemic"] = lambda x: _blueprofile(args=["mic"])
# Set bluetooth mode to enable high quality sound
carliases["bluesound"] = lambda x: _blueprofile(args=["music"])
# Add all carliases to aliases
aliases["aliasup"] = lambda x: _aliasupdown(carliases, True)
# Remove all carliases to aliases
aliases["aliasdown"] = lambda x: _aliasupdown(carliases, False)

# Add all aliases
_aliasupdown(carliases, True)
