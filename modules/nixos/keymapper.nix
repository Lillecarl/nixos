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
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.keymapper = {
      description = "Keymapper";
      wantedBy = [ "multi-user.target" ];
      #after = [ "systemd-user-sessions.service" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.keymapper}/bin/keymapperd -v";
        Restart = "always";
        RestartSec = "5";
      };
    };
  };
}
