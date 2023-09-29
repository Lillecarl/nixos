{ inputs
, config
, pkgs
, flakeloc
, keyboardName
, bluetooth
, monitorConfig
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

  cursorSettings = {
    name = "macOS-BigSur";
    size = 24;
    package = pkgs.apple-cursor;
  };

  wallpaper = "${inputs.nixos-artwork}/wallpapers/nix-wallpaper-watersplash.png";

  extraConfig = ''
    # Source from home-manager file that can be live edited through out of store symlinks.
    source = ${config.xdg.configHome}/hypr/linked.conf

    $mainMod = SUPER

    exec-once = ${pkgs.hyprpaper}/bin/hyprpaper
  '' +
  (if bluetooth then ''
    exec-once = ${pkgs.blueman}/bin/blueman-applet
  '' else ""
  )
  + ''
    # Per machine configured home configuration
    ${monitorConfig}

    # Launch terminal
    bind  = $mainMod          , Q       , exec, ${pkgs.wezterm}/bin/wezterm-gui
    # Awesome locker
    bind  = Ctrl_L Alt_L      , delete  , exec, ${pkgs.swaylock}/bin/swaylock
    # Media buttons
    bindl =                   , code:121, exec, ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle
    bindl =                   , code:122, exec, ${pkgs.avizo}/bin/volumectl down
    bindl =                   , code:123, exec, ${pkgs.avizo}/bin/volumectl up
    bindl =                   , code:198, exec, ${pkgs.mictoggle}
    # Increase and decrease screen backlight
    bindl =                   , code:232, exec, ${pkgs.avizo}/bin/lightctl down
    bindl =                   , code:233, exec, ${pkgs.avizo}/bin/lightctl up
    # drun app launcher
    bind  = $mainMod          , R       , exec, ${pkgs.rofi-wayland}/bin/rofi -show drun
    # search application window titles
    bind  = $mainMod          , tab     , exec, ${pkgs.rofi-wayland}/bin/rofi -show window
    # Switch to US layout
    bindl = $mainMod          , E       , exec, ${hyprctl} switchxkblayout ${keyboardName} 0
    # Switch to SE layout
    bindl = $mainMod          , S       , exec, ${hyprctl} switchxkblayout ${keyboardName} 1
    # Switch to EU layout
    bindl = $mainMod          , Y       , exec, ${hyprctl} switchxkblayout ${keyboardName} 2
    bind  =                   , Print   , exec, ${printScript} screen --edit --upload
    bind  = $mainMod          , Print   , exec, ${printScript} window --edit --upload
    bind  = $mainMod Shift_L  , Print   , exec, ${printScript} region --edit --upload
    bind  = Ctrl_L Alt_L      , V       , exec, ${pkgs.cliphist}/bin/cliphist list | ${pkgs.wofi}/bin/wofi --dmenu | ${pkgs.cliphist}/bin/cliphist decode | ${pkgs.wl-clipboard}/bin/wl-copy
  '' +
  builtins.readFile "${inputs.catppuccin-hyprland}/themes/mocha.conf";
in
{
  home.packages = [
    pkgs.rofi # Required for clipman picker
  ];
  gtk = {
    enable = true;

    theme = {
      name = "Catppuccin-Mocha-Compact-Pink-dark";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "pink" ];
        size = "compact";
        tweaks = [ "rimless" ];
        variant = "mocha";
      };
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
  #home.file.".config/hypr/hyprlandd.conf" = config.xdg.configFile."hypr/hyprland.conf";
  xdg.configFile."hypr/hyprlandd.conf".text = config.xdg.configFile."hypr/hyprland.conf".text;

  home.file.".config/hypr/hyprpaper.conf".text = ''
    preload = ${wallpaper}
    wallpaper = ,${wallpaper}
  '';

  services.gammastep.enable = false; # Screen temperature daemon. TODO: Enable and configure
  services.wlsunset.enable = false; # Screen temperature daemon. TODO: Enable and configure

  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland-carl;

    systemdIntegration = true;
    disableAutoreload = true;

    xwayland.enable = true;
    inherit extraConfig;
  };

  systemd.user.services.cliphist = {
    Unit = {
      Description = "wayland clipboard manager";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart =
        "${pkgs.wl-clipboard}/bin/wl-paste --watch ${pkgs.cliphist}/bin/cliphist store";
      ExecReload = "${pkgs.coreutils}/bin/kill -SIGUSR2 $MAINPID";
      Restart = "on-failure";
      KillMode = "mixed";
    };

    Install = { WantedBy = [ "hyprland-session.target" ]; };
  };
}
