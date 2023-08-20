{ inputs
, pkgs
, ...
}:
let
  hyprland-starter = pkgs.writeShellScript "hyprland-starter" ''
    export XDG_SESSION_TYPE=wayland
    export MOZ_ENABLE_WAYLAND=1
    export CLUTTER_BACKEND=wayland
    export QT_QPA_PLATFORM=wayland-egl
    export ECORE_EVAS_ENGINE=wayland-egl
    export ELM_ENGINE=wayland_egl
    export SDL_VIDEODRIVER=wayland

    "${inputs.hyprland.packages.${pkgs.system}.hyprland}/bin/Hyprland";
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
