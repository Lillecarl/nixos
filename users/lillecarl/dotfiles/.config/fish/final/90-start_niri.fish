if status --is-login && test "$XDG_VTNR" = 1
    set -x NIRI_LOGFILE /run/user/$(id -u)/niri.log

    set -e __HM_SESS_VARS_SOURCED
    set -e __NIXOS_SET_ENVIRONMENT_DONE

    exec sh -c "SHLVL=0 niri --session > $NIRI_LOGFILE"
end
