function waydisplay --on-event fish_preexec
    set WAYDISPLAY (fd --base-directory $XDG_RUNTIME_DIR wayland)[1]
    if test -S "$XDG_RUNTIME_DIR/$WAYDISPLAY"
        set -gx WAYLAND_DISPLAY $WAYDISPLAY
    end
end
