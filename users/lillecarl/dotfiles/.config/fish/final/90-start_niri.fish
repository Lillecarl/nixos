if status --is-login && test "$XDG_VTNR" = 2
    set -x NIRI_LOGFILE /run/user/$(id -u)/niri.log
    exec sh -c "SHLVL=0 niri --session > $NIRI_LOGFILE"
end
