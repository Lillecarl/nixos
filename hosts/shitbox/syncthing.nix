{ pkgs, config, ...}:
let
  domain = "syncthing.${config.networking.hostName}.lillecarl.com";
in
{
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;

    user = "lillecarl";
    dataDir = "/home/lillecarl/Syncthing";

    settings = {
      insecureSkipHostcheck = true;
    };
  };

  services.nginx = {
    enable = true;
    virtualHosts.${domain} = {
      locations."/" = {
        recommendedProxySettings = true;
        proxyPass = "http://${toString config.services.syncthing.guiAddress}";
        proxyWebsockets = true;
      };
      forceSSL = true;
      # Use host specific ACME wildcard certificate
      useACMEHost = config.networking.hostName;
    };
  };
  # Add domain to hosts
  networking.hosts = {
    ${config.lib.lobr.ip} = [ domain ];
  };
}
