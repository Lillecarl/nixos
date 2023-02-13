#! /usr/bin/env xonsh

# XONSH WEBCONFIG START
# XONSH WEBCONFIG END

# Standard imports
import time
import json
import platform
import os

from prompt_toolkit.keys import Keys
from shutil import which

# Set shell to xonsh (We're going to spawn a new shell)
$SHELL = "xonsh"

# xontribs

# Execute direnv in Xonsh
xontrib load direnv
# Allow banging shell scripts from xonsh
xontrib load sh
# Search previous commands output with Alt+f
$XONSH_CAPTURE_ALWAYS=True # Required for output_search
xontrib load output_search
# Replaces McFly, loads history into a fuzzy searcher TUI
$fzf_history_binding = Keys.ControlR
xontrib load fzf-widgets
# Jump words with control + arrows
xontrib load whole_word_jumping
# vox, pyenv for xonsh
xontrib load vox

# Because modal text editing makes sense
$VI_MODE = True
# Makes "cd" bareable with beautiful paths
$CASE_SENSITIVE_COMPLETIONS = False
# Somehow this fixes pagers
$THREAD_SUBPROCS = False

# Add bash completions to xonsh, not sure how this works but it's heaps cool.
$BASH_COMPLETIONS= ["/run/current-system/sw/share/bash-completion/bash_completion"]
# Helm completion
#source-bash $(helm completion bash) --suppress-skip-message

# Store command output in history database
$XONSH_STORE_STDOUT = True
# Use SQLite history backend
$XONSH_HISTORY_BACKEND = 'sqlite'
# Don't save commands prefixed with a space
$HISTCONTROL.add('ignorespace')
# Don't add the command twice to history if ran consecutively
$HISTCONTROL.add('ignoredups')
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

# If keychain binary exists, load ssh keys
if which("keychain"):
  # Load keychain bash environment stuff
  source-bash $(keychain --eval -q) --suppress-skip-message
  # Load personal key
  keychain -q id_ed25519
  # Load work keys
  if $HOSTNAME == "nub":
    keychain -q ed_viaplay
    keychain -q rsa_viaplay

