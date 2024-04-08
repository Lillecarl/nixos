if status --is-login
    and test "$XDG_VTNR" = 1
    exec sh -c "Hyprland &> /tmp/hyprland-session.log"
end
