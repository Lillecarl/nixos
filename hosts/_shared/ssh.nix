{ lib, config, ... }:
let
  modName = "ssh";
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
    services.openssh = {
      enable = true;

      openFirewall = true;

      settings = {
        UseDns = true;
        LogLevel = "VERBOSE"; # fail2ban
      };
    };
  };
}
