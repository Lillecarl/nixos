{ lib, config, ... }:
let
  modName = "dockerRegistry";
  cfg = config.ps.${modName};
  domain = "registry.${config.networking.hostName}.lillecarl.com";
in
{
  options.ps = {
    ${modName} = {
      enable = lib.mkOption {
        default = config.ps.server.enable;
        description = "Whether to enable ${modName}.";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    # Enable "docker" registry
    services.dockerRegistry = {
      enable = true;
      enableGarbageCollect = true;
      enableDelete = true;
      port = 5500;
    };
    # Proxy registry through nginx
    services.nginx = {
      enable = true;
      virtualHosts.${domain} = {
        locations."/" = {
          recommendedProxySettings = true;
          proxyPass = "http://127.0.0.1:${toString config.services.dockerRegistry.port}";
          proxyWebsockets = true;
        };
        forceSSL = true;
        # Use host specific ACME wildcard certificate
        useACMEHost = config.networking.hostName;
        # Allow posting uberhuge things like Docker image layers
        extraConfig = ''
          client_max_body_size 0;
        '';
      };
    };
    # Add domain to hosts
    networking.hosts = {
      ${config.lib.lobr.ip} = [ domain ];
    };
  };
}
