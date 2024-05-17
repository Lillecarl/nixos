#! /usr/bin/env fish

function __fish_CHLD --on-signal USR1
    set -x DIRENV_FINISHED y
    commandline -f repaint
end
