if status --is-login
    and test "$XDG_VTNR" = 2
    exec sh -c "niri-session &> /tmp/niri-session.log"
end
