{ inputs
, config
, pkgs
, flakeloc
, keyboardName
, ...
}:
let
  writePython3 = import ../../lib/writePython3.nix { inherit pkgs; };
  hyprctl = "${pkgs.hyprland}/bin/hyprctl";

  printScript = writePython3 "hyprprint"
    {
      libraries = [
        pkgs.grim
        pkgs.slurp
        pkgs.swappy
        pkgs.wl-clipboard
        pkgs.python3.pkgs.boto3
        pkgs.python3.pkgs.plumbum
      ];
    }
    (builtins.replaceStrings
      [
        "\"grim\""
        "\"slurp\""
        "\"swappy\""
        "\"hyprctl\""
        "\"wl-copy\""
      ]
      [
        "\"${pkgs.grim}/bin/grim\""
        "\"${pkgs.slurp}/bin/slurp\""
        "\"${pkgs.swappy}/bin/swappy\""
        "\"${hyprctl}\""
        "\"${pkgs.wl-clipboard}/bin/wl-copy\""
      ]
      (builtins.readFile ../../print.py));

  volScript = pkgs.writeScript "volScript" ''
    if [[ "$1" == "up" ]]
    then
      ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%
    else
      ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%
    fi
    ${pkgs.pulseaudio}/bin/pactl --format=json list sinks | ${pkgs.jq}/bin/jq ".[0].volume.\"front-left\".value_percent" -r | ${pkgs.gnused}/bin/sed "s/%//g" > /run/user/1000/wob.sock
  '';

  lightScript = pkgs.writeScript "lightScript" ''
    if [[ "$1" == "up" ]]
    then
      ${pkgs.light}/bin/light -A 5
    else
      ${pkgs.light}/bin/light -U 5
    fi
    ${pkgs.light}/bin/light -G > /run/user/1000/wob.sock
  '';

  cursorSettings = {
    name = "macOS-BigSur";
    size = 24;
    package = pkgs.apple-cursor;
  };

  wallpaper = "${inputs.nixos-artwork}/wallpapers/nix-wallpaper-watersplash.png";
in
{
  home.packages = [
    pkgs.rofi # Required for clipman picker
  ];
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
  home.file.".config/hypr/hyprlandd.conf".source = "${config.xdg.configHome}/hypr/hyprland.conf";

  home.file.".config/hypr/hyprpaper.conf".text = ''
    preload = ${wallpaper}
    wallpaper = ,${wallpaper}
  '';

  services.gammastep.enable = false; # Screen temperature daemon. TODO: Enable and configure
  services.wlsunset.enable = false; # Screen temperature daemon. TODO: Enable and configure

  services.clipman = {
    enable = true;
    package = pkgs.clipman-wrapped;
    systemdTarget = "hyprland-session.target";
  };

  wayland.windowManager.hyprland = {
    enable = true;

    systemdIntegration = true;
    disableAutoreload = true;

    xwayland.enable = true;

    extraConfig = ''
      # Source from home-manager file that can be live edited through out of store symlinks.
      source = ${config.xdg.configHome}/hypr/linked.conf

      $mainMod = SUPER

      exec-once = ${pkgs.hyprpaper}/bin/hyprpaper
      exec-once = ${pkgs.ulauncher}/bin/ulauncher --hide-window
      exec-once = ${pkgs.blueman}/bin/blueman-applet

      # Launch terminal
      bind  = $mainMod          , Q       , exec, ${pkgs.wezterm}/bin/wezterm-gui
      # Awesome locker
      bind  = Ctrl_L Alt_L      , delete  , exec, ${pkgs.swaylock}/bin/swaylock
      # Media buttons
      bindl =                   , code:121, exec, ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle
      bindl =                   , code:122, exec, ${volScript} down
      bindl =                   , code:123, exec, ${volScript} up
      bindl =                   , code:198, exec, ${pkgs.mictoggle}
      # Increase and decrease screen backlight
      bindl =                   , code:232, exec, ${lightScript} down
      bindl =                   , code:233, exec, ${lightScript} up
      # drun app launcher
      bind  = $mainMod          , R       , exec, ${pkgs.rofi-wayland}/bin/rofi -show drun
      # search application window titles
      bind  = $mainMod          , tab     , exec, ${pkgs.rofi-wayland}/bin/rofi -show window
      # Switch to US layout
      bindl = $mainMod          , E       , exec, ${hyprctl} switchxkblayout ${keyboardName} 0
      # Switch to SE layout
      bindl = $mainMod          , S       , exec, ${hyprctl} switchxkblayout ${keyboardName} 1
      bind  =                   , Print   , exec, ${printScript} screen --edit --upload
      bind  = $mainMod          , Print   , exec, ${printScript} window --edit --upload
      bind  = $mainMod Shift_L  , Print   , exec, ${printScript} region --edit --upload
      bind  = Ctrl_L Alt_L      , V       , exec, ${pkgs.clipman}/bin/clipman pick --tool=rofi
    '';
  };
}
