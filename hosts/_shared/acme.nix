{ lib, config, ... }:
let
  modName = "acme";
  cfg = config.ps.${modName};
  hostname = config.networking.hostName;
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
    security.acme = {
      acceptTerms = true;

      defaults = {
        email = "le@lillecarl.com";
        dnsProvider = "cloudflare";
        dnsResolver = "1.1.1.1:53";
        environmentFile = config.age.secrets.cloudflare.path;
      };

      certs.${hostname} = {
        domain = "${hostname}.lillecarl.com";
        extraDomainNames = [ "*.${hostname}.lillecarl.com" ];
      };
    };
    users.users.nginx.extraGroups = [
      config.security.acme.defaults.group
    ];
  };
}
