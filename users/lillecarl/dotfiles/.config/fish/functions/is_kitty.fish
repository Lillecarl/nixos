# check if the terminal is kitty, but not really
function is_kitty
    # zellij and tmux can't handle kitty escape codes
    set -q ZELLIJ && return 1
    set -q TMUX && return 1
    # is kitty if $TERM is xterm-kitty
    test $TERM = xterm-kitty && return 0 || return 1
end
