{ inputs
, config
, pkgs
, keyboardName
, bluetooth
, monitorConfig
, bp
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
        "\"${bp pkgs.grim}\""
        "\"${bp pkgs.slurp}\""
        "\"${bp pkgs.swappy}\""
        "\"${hyprctl}\""
        "\"${pkgs.wl-clipboard}/bin/wl-copy\""
      ]
      (builtins.readFile ../../scripts/print.py));

  wallpaper = "${inputs.nixos-artwork}/wallpapers/nix-wallpaper-watersplash.png";

  extraConfig = with pkgs; ''
    # Lock as soon as we're logged in
    exec-once = ${bp pkgs.swaylock}
    # Source from home-manager file that can be live edited through out of store symlinks.
    source = ${config.xdg.configHome}/hypr/linked.conf

    $mainMod = SUPER

    exec-once = ${bp pkgs.hyprpaper}
  '' +
  (if bluetooth then ''
    exec-once = ${pkgs.blueman}/bin/blueman-applet
  '' else ""
  )
  + ''
    # Per machine configured home configuration
    ${monitorConfig}

    # Always spawn alacritty in special workspace
    workspace = special:magic, on-created-empty:${bp kitty} -1, gapsout:75, gapsin:30
    workspace = 1, on-created-empty:${bp kitty} -1
    workspace = 2, on-created-empty:${bp firefox}

    # Launch terminal
    bind  = $mainMod          , Q       , exec, ${bp kitty} -1
    # Awesome locker
    bind  = Ctrl_L Alt_L      , delete  , exec, ${bp swaylock}
    # Media buttons
    bindl =                   , code:121, exec, ${pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle
    bindl =                   , code:122, exec, ${avizo}/bin/volumectl down
    bindl =                   , code:123, exec, ${avizo}/bin/volumectl up
    bindl =                   , code:198, exec, ${mictoggle}
    # Increase and decrease screen backlight
    bindl =                   , code:232, exec, ${avizo}/bin/lightctl down
    bindl =                   , code:233, exec, ${avizo}/bin/lightctl up
    # drun app launcher
    bind  = $mainMod          , R       , exec, ${bp rofi-wayland} -show drun
    # search application window titles
    bind  = $mainMod          , tab     , exec, ${bp rofi-wayland} -show window
    # Switch keyboard layout
    bindl = $mainMod          , E       , exec, ${hyprctl} switchxkblayout ${keyboardName} next
    bind  =                   , Print   , exec, ${printScript} screen --edit --upload
    bind  = $mainMod          , Print   , exec, ${printScript} window --edit --upload
    bind  = $mainMod Shift_L  , Print   , exec, ${printScript} region --edit --upload
    bind  = Ctrl_L Alt_L      , V       , exec, ${bp cliphist} list | ${bp wofi} --dmenu | ${bp cliphist} decode | ${wl-clipboard}/bin/wl-copy
  '';
in
{
  home.packages = [
    pkgs.rofi-wayland # Required for clipman picker
    pkgs.nwg-displays
    pkgs.wlr-randr
  ];

  xdg.configFile."hypr/hyprlandd.conf".text = config.xdg.configFile."hypr/hyprland.conf".text;
  home.file.".config/hypr/hyprpaper.conf".text = ''
    preload = ${wallpaper}
    wallpaper = ,${wallpaper}
  '';

  services.gammastep.enable = false; # Screen temperature daemon. TODO: Enable and configure
  services.wlsunset.enable = false; # Screen temperature daemon. TODO: Enable and configure

  wayland.windowManager.hyprland = {
    enable = true;

    systemd.enable = true;
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
        "${pkgs.wl-clipboard}/bin/wl-paste --watch ${bp pkgs.cliphist} store";
      ExecReload = "${pkgs.coreutils-full}/bin/kill -SIGUSR2 $MAINPID";
      Restart = "on-failure";
      KillMode = "mixed";
    };

    Install = { WantedBy = [ "hyprland-session.target" ]; };
  };

  systemd.user.services.miclight =
    let
      dep = "pipewire-pulse.service";
    in
    {
      Unit = {
        Description = "Mutes microphone and turns off light";
        PartOf = [ dep ];
        After = [ dep ];
      };

      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.miconoff} 1";
      };

      Install = { WantedBy = [ dep ]; };
    };
}
