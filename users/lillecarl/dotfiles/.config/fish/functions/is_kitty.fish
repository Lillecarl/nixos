function is_kitty
    test $TERM = xterm-kitty && return 0 || return 1
end
