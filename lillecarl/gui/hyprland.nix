{ inputs
, config
, lib
, pkgs
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
      (builtins.readFile ../../scripts/print.py));

  wallpaper = "${inputs.nixos-artwork}/wallpapers/nix-wallpaper-watersplash.png";

  extraConfig = ''
    # Lock as soon as we're logged in
    exec-once = ${pkgs.swaylock}/bin/swaylock
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
    bind  = $mainMod          , Q       , exec, ${config.programs.wezterm.package}/bin/wezterm-gui
    #bind  = $mainMod          , Q       , exec, ${pkgs.foot}/bin/footclient
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
    # Switch keyboard layout
    bindl = $mainMod          , E       , exec, ${hyprctl} switchxkblayout ${keyboardName} next
    bind  =                   , Print   , exec, ${printScript} screen --edit --upload
    bind  = $mainMod          , Print   , exec, ${printScript} window --edit --upload
    bind  = $mainMod Shift_L  , Print   , exec, ${printScript} region --edit --upload
    bind  = Ctrl_L Alt_L      , V       , exec, ${pkgs.cliphist}/bin/cliphist list | ${pkgs.wofi}/bin/wofi --dmenu | ${pkgs.cliphist}/bin/cliphist decode | ${pkgs.wl-clipboard}/bin/wl-copy
  '';
in
{
  home.packages = [
    pkgs.rofi-wayland # Required for clipman picker
    pkgs.nwg-displays
    pkgs.wlr-randr
  ];

  xdg.configFile."hypr/hyprlandd.conf".text = config.xdg.configFile."hypr/hyprland.conf".text;
  xdg.configFile."hypr/hyprland.conf".onChange = lib.mkForce ''
    ( # Execute in subshell so we don't poision environment with vars
      # This var must be set for hyprctl to function, but the value doesn't matter.
      export HYPRLAND_INSTANCE_SIGNATURE="bogus"
      for i in $(${pkgs.hyprland}/bin/hyprctl instances -j | jq ".[].instance" -r); do
        export HYPRLAND_INSTANCE_SIGNATURE=$i
        ${pkgs.hyprland}/bin/hyprctl reload config-only
      done
    )
  '';

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
        "${pkgs.wl-clipboard}/bin/wl-paste --watch ${pkgs.cliphist}/bin/cliphist store";
      ExecReload = "${pkgs.coreutils}/bin/kill -SIGUSR2 $MAINPID";
      Restart = "on-failure";
      KillMode = "mixed";
    };

    Install = { WantedBy = [ "hyprland-session.target" ]; };
  };

  systemd.user.services.miclight = let
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
