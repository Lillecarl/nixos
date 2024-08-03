function is_kitty
    set -q ZELLIJ && return 1
    test $TERM = xterm-kitty && return 0 || return 1
end
