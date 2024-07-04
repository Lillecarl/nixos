{ config, ... }:
let
  hostname = config.networking.hostName;
in
{
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
}
