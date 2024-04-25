{ config
, inputs
, lib
, pkgs
, self
, nixosConfig
, ...
}:
let
  carlCfg = config.carl;
  cfg = config.carl.gui.hyprland;
in
{
  options.carl.gui.hyprland = with lib; {
    enable = mkOption {
      type = types.bool;
      default = carlCfg.gui.enable;
      description = "Enable Hyprland";
    };
    monitorConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Extra configuration for monitor setup";
    };
    keyboardName = mkOption {
      type = types.str;
      default = "";
      description = "Name of the keyboard to switch layout on with binds";
    };
  };
  config =
    let
      writePython3 = import "${self}/lib/writePython3.nix" { inherit pkgs; };
      hyprctl = "${pkgs.hyprland}/bin/hyprctl";

      lockScript = config.home.file."swayLockScript".source;

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
            "\"${lib.getExe pkgs.grim}\""
            "\"${lib.getExe pkgs.slurp}\""
            "\"${lib.getExe pkgs.swappy}\""
            "\"${hyprctl}\""
            "\"${pkgs.wl-clipboard}/bin/wl-copy\""
          ]
          (builtins.readFile "${self}/scripts/print.py"));

      extraConfig = with pkgs; ''
        # Source from home-manager file that can be live edited through out of store symlinks.
        source = ${config.xdg.configHome}/hypr/linked.conf

        $mainMod = SUPER

        exec-once = ${lib.getExe pkgs.hyprpaper}
      '' +
      (if config.carl.bluetooth.enable then ''
        exec-once = ${pkgs.blueman}/bin/blueman-applet
      '' else ""
      )
      + ''
        # Per machine configured home configuration
        ${cfg.monitorConfig}

        # Always spawn alacritty in special workspace
        workspace = special:magic, on-created-empty:${lib.getExe kitty} -1, gapsout:75, gapsin:30
        workspace = 1, on-created-empty:${lib.getExe kitty} -1
        workspace = 2, on-created-empty:${lib.getExe config.programs.firefox.package}

        # Launch terminal
        bind  = $mainMod          , Q       , exec, ${lib.getExe kitty} -1
        # Awesome locker
        bind  = Ctrl_L Alt_L      , delete  , exec, ${lockScript}
        # Media buttons
        bindl =                   , code:121, exec, ${pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle
        bindl =                   , code:122, exec, ${avizo}/bin/volumectl down
        bindl =                   , code:123, exec, ${avizo}/bin/volumectl up
        bindl =                   , code:198, exec, ${mictoggle}
        # Increase and decrease screen backlight
        bindl =                   , code:232, exec, ${avizo}/bin/lightctl down
        bindl =                   , code:233, exec, ${avizo}/bin/lightctl up
        # drun app launcher
        bind  = $mainMod          , R       , exec, ${lib.getExe rofi-wayland} -show drun
        # search application window titles
        bind  = $mainMod          , tab     , exec, ${lib.getExe rofi-wayland} -show window
        # Switch keyboard layout
        bindl = $mainMod          , E       , exec, ${hyprctl} switchxkblayout ${cfg.keyboardName} next
        bind  =                   , Print   , exec, ${printScript} screen --edit --upload
        bind  = $mainMod          , Print   , exec, ${printScript} window --edit --upload
        bind  = $mainMod Shift_L  , Print   , exec, ${printScript} region --edit --upload
        bind  = Ctrl_L Alt_L      , V       , exec, ${lib.getExe cliphist} list | ${lib.getExe wofi} --dmenu | ${lib.getExe cliphist} decode | ${wl-clipboard}/bin/wl-copy
      '';
    in
    lib.mkIf cfg.enable {
      carl.gui.systemdTarget = "hyprland-session.target";

      home.packages = [
        pkgs.rofi-wayland # Required for clipman picker
        pkgs.nwg-displays
        pkgs.wlr-randr
      ];

      xdg.configFile."hypr/hyprlandd.conf".text = config.xdg.configFile."hypr/hyprland.conf".text;

      services.gammastep.enable = false; # Screen temperature daemon. TODO: Enable and configure
      services.wlsunset.enable = false; # Screen temperature daemon. TODO: Enable and configure

      wayland.windowManager.hyprland = {
        enable = true;

        package = nixosConfig.programs.hyprland.package;

        systemd.enable = true;
        xwayland.enable = true;
        inherit extraConfig;

        plugins = [
        ] ++ nixosConfig.programs.hyprland.plugins;
      };

      systemd.user.services.cliphist = {
        Unit = {
          Description = "wayland clipboard manager";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };

        Service = {
          ExecStart =
            "${pkgs.wl-clipboard}/bin/wl-paste --watch ${lib.getExe pkgs.cliphist} store";
          ExecReload = "${pkgs.coreutils-full}/bin/kill -SIGUSR2 $MAINPID";
          Restart = "on-failure";
          KillMode = "mixed";
        };

        Install = { WantedBy = [ "hyprland-session.target" ]; };
      };
    };
}
