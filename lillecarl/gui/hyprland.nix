{ inputs
, config
, pkgs
, flakeloc
, ...
}:
let
  hyprctl = "${inputs.hyprland.packages.${pkgs.system}.hyprland}/bin/hyprctl";

  cursorSettings = {
    name = "macOS-BigSur";
    size = 24;
    package = pkgs.apple-cursor;
  };

  wallpaper = "${inputs.nixos-artwork}/wallpapers/nix-wallpaper-watersplash.png";
in
{
  gtk = {
    enable = true;

    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome.gnome-themes-extra;
    };

    iconTheme = {
      name = "Adwaita";
      package = pkgs.gnome.adwaita-icon-theme;
    };

    cursorTheme = cursorSettings;
  };

  qt = {
    enable = true;
    platformTheme = "gtk";
  };

  home.pointerCursor = cursorSettings // {
    gtk.enable = true;
    x11.enable = true;
  };

  home.file.".config/hypr/linked.conf".source = config.lib.file.mkOutOfStoreSymlink "${flakeloc}/lillecarl/gui/hyprland.conf";

  home.file.".config/hypr/hyprpaper.conf".text = ''
    preload = ${wallpaper}
    wallpaper = ,${wallpaper}
  '';

  services.gammastep.enable = false; # Screen temperature daemon. TODO: Enable and configure
  services.wlsunset.enable = false; # Screen temperature daemon. TODO: Enable and configure

  services.clipman = {
    enable = true;
    systemdTarget = "hyprland-session.target";
  };

  wayland.windowManager.hyprland = {
    enable = true;

    xwayland.enable = true;

    extraConfig = ''
      # Source from home-manager file that can be live edited through out of store symlinks.
      source = ${config.xdg.configHome}/hypr/linked.conf

      # shitbox monitor layout
      monitor=DP-1,2560x1440@164.802002,1080x240,1.0
      monitor=DVI-D-2,1920x1080@143.996002,0x0,1.0
      monitor=DVI-D-2,transform,3

      $mainMod = SUPER

      exec-once = ${pkgs.hyprpaper}/bin/hyprpaper
      exec-once = ${pkgs.ulauncher}/bin/ulauncher --hide-window
      exec-once = ${pkgs.blueman}/bin/blueman-applet

      # Launch terminal
      bind  = $mainMod     , Q       , exec, ${pkgs.wezterm}/bin/wezterm-gui
      # Awesome locker
      bind  = Ctrl_L Alt_L , delete  , exec, ${pkgs.swaylock}/bin/swaylock
      # Media buttons
      bindl =             , code:121, exec, ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle
      bindl =             , code:122, exec, ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%
      bindl =             , code:123, exec, ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%
      bindl =             , code:198, exec, ${pkgs.mictoggle}
      # Increase and decrease screen backlight
      bindl =             , code:232, exec, ${pkgs.light}/bin/light -U 5
      bindl =             , code:233, exec, ${pkgs.light}/bin/light -A 5
      # drun app launcher
      bind  = $mainMod    , R       , exec, ${pkgs.rofi-wayland}/bin/rofi -show drun
      # search application window titles
      bind  = $mainMod    , tab     , exec, ${pkgs.rofi-wayland}/bin/rofi -show window
      # Switch to US layout
      bindl = $mainMod, E, exec, ${hyprctl} switchxkblayout at-translated-set-2-keyboard 0
      # Switch to SE layout
      bindl = $mainMod, S, exec, ${hyprctl} switchxkblayout at-translated-set-2-keyboard 1
    '';
  };
}
