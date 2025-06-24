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
    # The defaults for this module sucks imo, way too strict for real use.
    services.fail2ban = {
      enable = true;
      maxretry = 10; # default: 3
      bantime = "1m"; # default: 10m
      # Enable multiplying bantime by times banned
      bantime-increment.enable = true;
      # Share IP ban/counter database across all jails
      bantime-increment.overalljails = true;
    };
  };
}
