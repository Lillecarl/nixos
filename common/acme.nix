{ ... }:
{
  security.acme = {
    acceptTerms = true;

    defaults.email = "le@lillecarl.com";
    defaults.dnsProvider = "cloudflare";
    defaults.dnsResolver = "1.1.1.1:53";
    defaults.environmentFile = "/var/hemlisar/cloudflare.env";
  };
}
