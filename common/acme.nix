_:
{
  security.acme = {
    acceptTerms = true;

    defaults = {
      email = "le@lillecarl.com";
      dnsProvider = "cloudflare";
      dnsResolver = "1.1.1.1:53";
      environmentFile = "/var/hemlisar/cloudflare.env";
    };
  };
}
