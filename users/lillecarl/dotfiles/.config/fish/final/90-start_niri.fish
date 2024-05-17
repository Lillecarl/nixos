if status --is-login && test "$XDG_VTNR" = 2
    exec niri --session
end
