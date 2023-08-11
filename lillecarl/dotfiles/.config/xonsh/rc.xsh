#! /usr/bin/env xonsh

# XONSH WEBCONFIG START
# XONSH WEBCONFIG END

import os

if "ASCIINEMA_REC" not in ${...}:
   from datetime import datetime as _datetime
   exec asciinema rec -q -c xonsh @("{0}.rec".format(os.path.join("/home/lillecarl/recordings", _datetime.now().isoformat())))

import time
import json
import platform
import os
import re as _re
from from_ssv import from_ssv

from prompt_toolkit.keys import Keys
from shutil import which

old_subprocs = $THREAD_SUBPROCS
$THREAD_SUBPROCS = None

# Set shell to xonsh (We're going to spawn a new shell)
$SHELL = "xonsh"

# Monitor how many shells deep we are
if "DEPTH" in ${...}:
  $DEPTH = int($DEPTH) + 1
else:
  $DEPTH=0

# xontribs

$fzf_history_binding = Keys.ControlR

from xonsh.xontribs import get_xontribs
_xontribs_installed = set(get_xontribs().keys())

_xontribs_to_load = (
  "abbrevs",
  "back2dir",
  "direnv",
  "fzf-widgets",
  "output_search",
  "sh",
  "vox",
  "whole_word_jumping",
)
xontrib load @(_xontribs_installed.intersection(_xontribs_to_load))

# Clean up prompt stuff from output_search
$XONTRIB_OUTPUT_SEARCH_REGEXES = [
  _re.compile(r'at \d{2}:\d{2}:\d{2}(\.\d+)?'),
  _re.compile(r'~.* 🐚 xonsh'),
  _re.compile(r'took [0-9|h|m|s]*s')
]

# Globbing files with “*” or “**” will also match dotfiles, or those ‘hidden’ files whose names begin with a literal ‘.’. 
# Note! This affects also on rsync and other tools.
$DOTGLOB = True

# Flag for automatically pushing directories onto the directory stack i.e. `dirs -p` (https://xon.sh/aliases.html#dirs).
$AUTO_PUSHD = True

# Because modal text editing makes sense
$VI_MODE = True
# Makes "cd" bareable with beautiful paths
$CASE_SENSITIVE_COMPLETIONS = False

# Add bash completions to xonsh, not sure how this works but it's heaps cool.
$BASH_COMPLETIONS= ["/run/current-system/sw/share/bash-completion/bash_completion"]
# Add carapace completions
# exec($(carapace _carapace xonsh))

# Store command output in history database
$XONSH_STORE_STDOUT = True
# Use SQLite history backend
$XONSH_HISTORY_BACKEND = 'sqlite'
# Don't save commands prefixed with a space
$HISTCONTROL.add('ignorespace')
# Don't add the command twice to history if ran consecutively
$HISTCONTROL.add('ignoredups')
# Set regex to avoid saving unwanted commands
# Do not write the command to the history if it was ended by `###`
$XONSH_HISTORY_IGNORE_REGEX = '.*(\\#\\#\\#\\s*)$'
# Indent with two spaces, not four in CLI
$INDENT = '  '
# Auto cd (Change dir without typing cd)
$AUTO_CD = True

# Starship prompt
execx($(starship init xonsh))

$EDITOR = "nvim"
$VISUAL = "nvim"
$PAGER = "moar"

if "HOME" not in ${...}:
  $HOME = "/home/{0}".format($USER)
# https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html#variables
if "XDG_CACHE_HOME" not in ${...}:
  $XDG_CACHE_HOME = $HOME/.cache
if "XDG_CONFIG_HOME" not in ${...}:
  $XDG_CONFIG_HOME = $HOME/.config
if "XDG_BIN_HOME" not in ${...}:
  $XDG_BIN_HOME = $HOME/.local/bin
if "XDG_DATA_HOME" not in ${...}:
  $XDG_DATA_HOME = $HOME/.local/share
if "XDG_STATE_HOME" not in ${...}:
  $XDG_STATE_HOME = $HOME/.local/state
if "NODE_HOME" not in ${...}:
  $XDG_STATE_HOME = $HOME/.local/node

# Add XDG_BIN_HOME to $PATH
$PATH.add($XDG_BIN_HOME)

# Add note stuff to $PATH
$PATH.add($NODE_HOME)
$NODE_PATH=$NODE_HOME+"/lib/node_modules"

$GPG_TTY=$(tty)

# If keychain binary exists, load ssh keys
if which("keychain"):
  # Load keychain bash environment stuff
  source-bash $(keychain --eval -q) --suppress-skip-message
  # Load personal key
  keychain -q id_ed25519

$THREAD_SUBPROCS = old_subprocs
