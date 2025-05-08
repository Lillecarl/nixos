set -x NIRI_LOGFILE /run/user/$(id -u)/niri.log
set -e __HM_SESS_VARS_SOURCED
set -e __NIXOS_SET_ENVIRONMENT_DONE

if status --is-login && test "$XDG_VTNR" = 1
    fc-cache -rv # Clean fontcache
    env --unset=SHLVL niri --session >$NIRI_LOGFILE
    systemctl --user stop niri-session.target
    exec echo "niri session exited, goodbye"
    exit
end
if status --is-login && test "$XDG_VTNR" = 2
    fc-cache -rv # Clean fontcache
    systemctl --user stop graphical-session.target
    # Save all environment variables to a file which will be used by the niri
    # systemd unit. Except for "SHLVL" since it's visible in my fish prompt.
    env | rg --no-config -v SHLVL >$XDG_RUNTIME_DIR/nirienv
    systemctl --user --wait start niri
    exit
end
