{ lib, config, ... }:
let
  modName = "samba";
  cfg = config.ps.${modName};
in
{
  options.ps = {
    ${modName} = {
      enable = lib.mkOption {
        default = false;
        description = "Whether to enable ${modName}.";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    services.samba = {
      enable = true;

      nsswins = true;
      enableNmbd = true;
      enableWinbindd = true;
      shares = {
        public = {
          path = "/home/lillecarl/Documents";
          comment = "Linux documents";
          browseable = true;
          "guest ok" = false;
          "read only" = false;
        };
      };
    };
  };
}
