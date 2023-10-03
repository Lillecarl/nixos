{ inputs
, pkgs
, ...
}:
let
  gdb-starter = pkgs.writeShellScript "gdb-hyprland-starter" ''
    echo "run" > /tmp/gdbcommands
    echo "shell echo -e \"\nCRASHLOG BEGIN\n\"" >> /tmp/gdbcommands
    echo "info program" >> /tmp/gdbcommands
    echo "shell echo -e \"\nBACKTRACE\n\"" >> /tmp/gdbcommands
    echo "bt" >> /tmp/gdbcommands
    echo "shell echo -e \"\nBACKTRACE FULL\n\"" >> /tmp/gdbcommands
    echo "bt full" >> /tmp/gdbcommands
    echo "shell echo -e \"\nTHREADS\n\"" >> /tmp/gdbcommands
    echo "info threads" >> /tmp/gdbcommands
    echo "shell echo -e \"\nTHREADS BACKTRACE\n\"" >> /tmp/gdbcommands
    echo "thread apply all bt full" >> /tmp/gdbcommands
    chmod +x /tmp/gdbcommands

    export WLR_NO_HARDWARE_CURSORS=1

    NOW=$(date -u +%Y-%m-%dT%H:%M:%S%Z)

    ${pkgs.gdb}/bin/gdb \
      ${pkgs.hyprland-carl}/bin/Hyprland \
      --batch \
      -x /tmp/gdbcommands |& tee /tmp/hyprlog-$NOW
  '';

  hyprland-starter = pkgs.writeShellScript "hyprland-starter" ''
    export XDG_SESSION_TYPE=wayland
    export MOZ_ENABLE_WAYLAND=1
    export CLUTTER_BACKEND=wayland
    export QT_QPA_PLATFORM=wayland-egl
    export ECORE_EVAS_ENGINE=wayland-egl
    export ELM_ENGINE=wayland_egl
    export SDL_VIDEODRIVER=wayland

    exec ${gdb-starter}
  '';
in
{
  services.greetd = {
    enable = true;

    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --user-menu --asterisks --time --cmd ${hyprland-starter}";
      };
    };
  };
}
