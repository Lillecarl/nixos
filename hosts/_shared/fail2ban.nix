{ lib, config, ... }:
let
  modName = "fail2ban";
  cfg = config.ps.${modName};
in
{
  options.ps = {
    ${modName} = {
      enable = lib.mkOption {
        default = true;
        description = "Whether to enable ${modName}.";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    services.fail2ban = {
      enable = true;
    };
  };
}
