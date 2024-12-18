function zellisesh
    # Unset __HM_SESS_VARS_SOURCED so new shells get updated variables
    set -u __HM_SESS_VARS_SOURCED
    # Set WAYLAND_DISPLAY as a universal variable so it's shared between all
    # fish instances.
    set WAYLAND_DISPLAY_ORIG $WAYLAND_DISPLAY
    set -u WAYLAND_DISPLAY
    set -Ux WAYLAND_DISPLAY $WAYLAND_DISPLAY_ORIG
    # Attach to zellij or create a new session
    zellij attach || zellij
end
