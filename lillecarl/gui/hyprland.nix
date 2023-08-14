{ inputs
, config
, pkgs
, self
, ...
}:
let
  hyprctl = "${inputs.hyprland.packages.${pkgs.system}.hyprland}/bin/hyprctl";

  cursorSettings = {
    name = "macOS-BigSur";
    size = 24;
    package = pkgs.apple-cursor;
  };
in
{
  gtk = {
    cursorTheme = cursorSettings // {
      gtk.enable = true;
      x11.enable = true;
    };
  };

  home.pointerCursor = cursorSettings;
  home.file.".config/hypr/linked.conf".source = config.lib.file.mkOutOfStoreSymlink "/home/lillecarl/Code/nixos/lillecarl/gui/hyprland.conf";

  wayland.windowManager.hyprland = {
    enable = true;

    xwayland.enable = true;


    extraConfig = ''
      # Source from home-manager file that can be live edited through out of store symlinks.
      source = ${config.xdg.configHome}/hypr/linked.conf

      $mainMod = SUPER
      
      exec-once = ${pkgs.waybar}/bin/waybar & ${pkgs.hyprpaper}/bin/hyprpaper
      
      bind = $mainMod     , Q       , exec, ${pkgs.wezterm}/bin/wezterm-gui
      bind = Ctrl_L Alt_L , delete  , exec, ${pkgs.swaylock}/bin/swaylock -i ${self}/resources/lockscreen.jpg -s center --color 000000
      bindl =             , code:121, exec, ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle
      bindl =             , code:122, exec, ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%
      bindl =             , code:123, exec, ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%
      bindl =             , code:198, exec, ${pkgs.mictoggle}
      bindl =             , code:232, exec, ${pkgs.light}/bin/light -U 10
      bindl =             , code:233, exec, ${pkgs.light}/bin/light -A 10
      bind  = $mainMod    , R       , exec, ${pkgs.rofi-wayland}/bin/rofi -show drun
      bind  = $mainMod    , tab     , exec, ${pkgs.rofi-wayland}/bin/rofi -show window
    '';
  };
}
