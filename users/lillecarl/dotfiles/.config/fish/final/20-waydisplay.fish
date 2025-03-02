function waydisplay --on-event fish_preexec
    set -q SSH_CLIENT || return 0 # Only set WAYLAND_DISPLAY in SSH connections
    set WAYDISPLAY (fd --base-directory $XDG_RUNTIME_DIR wayland)[1]
    if test -S "$XDG_RUNTIME_DIR/$WAYDISPLAY"
        set -gx WAYLAND_DISPLAY $WAYDISPLAY
    end
end
