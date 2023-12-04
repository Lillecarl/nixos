{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.services.keymapper;
in
{
  options = {
    services.keymapper = {
      enable = lib.mkEnableOption "keymapper";

      systemdTarget = lib.mkOption {
        type = lib.types.str;
        default = "graphical-session.target";
        example = "sway-session.target";
        description = ''
          Systemd target to bind to.
        '';
      };

      extraConfig = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Keymapper configuration";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.keymapper = {
      Unit = {
        X-SwitchMethod="restart";
        X-ConfigHash = (builtins.hashString "md5" cfg.extraConfig);
        Description = "Keymapper";
      };
      Service = {
        ExecStart = "${pkgs.keymapper}/bin/keymapper -v -c ${config.xdg.configHome + "/keymapper/keymapper.conf"}";
        Restart = "always";
        RestartSec = "5";
      };
      Install = {
        WantedBy = [ cfg.systemdTarget ];
      };
    };

    xdg.configFile."keymapper/keymapper.conf".text = cfg.extraConfig;
  };
}
