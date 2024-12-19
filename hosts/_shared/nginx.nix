{ lib, config, ... }:
let
  modName = "nginx";
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
    services.nginx.enable = true;
    users.users.nginx.extraGroups = [
      config.security.acme.defaults.group
    ];
  };
}
