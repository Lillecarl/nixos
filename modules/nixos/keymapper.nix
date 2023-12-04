{ pkgs
, lib
, config
, ...
}:
let
  cfg = config.services.keymapper;
in
{
  options = {
    services.keymapper = {
      enable = lib.mkEnableOption "keymapper";
      extraArgs = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Extra arguments to pass to keymapperd";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.keymapper = {
      description = "Keymapper";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.keymapper}/bin/keymapperd ${lib.concatStringsSep " " cfg.extraArgs}";
        Restart = "always";
        RestartSec = "5";
      };
    };
  };
}
