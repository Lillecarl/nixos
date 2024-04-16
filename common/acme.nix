{ config, ... }:
{
  security.acme = {
    acceptTerms = true;

    defaults = {
      email = "le@lillecarl.com";
      dnsProvider = "cloudflare";
      dnsResolver = "1.1.1.1:53";
      environmentFile = config.age.secrets.cloudflare.path;
    };
  };
}
