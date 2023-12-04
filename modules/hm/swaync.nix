{ config
, pkgs
, lib
, ...
}:
let
  cfg = config.services.swaync;
in
with lib; {
  options = {
    services.swaync = {
      enable = mkEnableOption "swaync";
      systemdTarget = mkOption {
        type = types.str;
        default = "graphical-session.target";
        example = "sway-session.target";
        description = ''
          Systemd target to bind to.
        '';
      };
      settings = mkOption {
        type = types.attrs;
        default = { };
        description = ''
          See man:swaync(5) for details.
        '';
      };
    };
  };
  config = mkIf cfg.enable {
    home.packages = [ pkgs.swaynotificationcenter ];

    systemd.user.services.swaync = {
      Unit = {
        Description = "Sway notification center";
        Documentation = "man:swaync(5)";
        PartOf = [ "graphical-session.target" ];
        ConditionEnvironment = "WAYLAND_DISPLAY";
      };
      Service = {
        Type = "dbus";
        BusName = "org.freedesktop.Notifications";
        ExecStart = "${pkgs.swaynotificationcenter}/bin/swaync";
        ExecReload = concatStringsSep " ; " [
          "${pkgs.swaynotificationcenter}/bin/swaync --reload-config"
          "${pkgs.swaynotificationcenter}/bin/swaync-client --reload-css"
        ];
        X-RestartIfChanged = (builtins.hashString "md5" (builtins.toJSON cfg.settings));
      };
      Install = { WantedBy = [ cfg.systemdTarget ]; };
    };

    xdg.configFile."swaync/config.json".text = builtins.toJSON cfg.settings;
  };
}
