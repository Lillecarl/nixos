{ config, pkgs, self, inputs, lib, ... }:
let
  alias = "auth";
  topDomain = "lillecarl.com";
  domain = "${alias}.${topDomain}";

  certPath = config.security.acme.certs.${alias}.directory;
  httpPort = 20080;
  httpsPort = 20443;
in
if false then { } else {
  containers.keycloak = {
    autoStart = true;
    specialArgs = {
      hostConfig = config;
      hostPkgs = pkgs;
      inherit self inputs;
    };
    bindMounts.auth = {
      hostPath = certPath;
      mountPoint = certPath;
    };

    config = { config, pkgs, lib, hostConfig, hostPkgs, ... }: {
      imports = [
        ../_shared/nix.nix
      ];

      environment.systemPackages = [
        pkgs.kitty.terminfo
        config.services.keycloak.package
      ];

      services.openssh.ports = [ 20022 ];

      services.keycloak = {
        enable = true;

        sslCertificate = "${certPath}/fullchain.pem";
        sslCertificateKey = "${certPath}/key.pem";

        database = {
          type = "postgresql";
          createLocally = true;

          username = "lillecarl";
          passwordFile = "${pkgs.writeText "keycloak-db-password" "lillecarl"}";
        };

        plugins = [
          (builtins.fetchurl {
            url = "https://github.com/sweid4keycloak/bankid4keycloak/releases/download/v24.0.0/bankid4keycloak-24.0.0.jar";
            sha256 = "sha256:062mvnym9zi6c7ia3jjjpvqk5092pymfnp5wc86r49y8qi7qdrj0";
          })
        ];

        themes = {
          bankid = pkgs.stdenv.mkDerivation {
            name = "bankid-theme";
            src = pkgs.fetchFromGitHub {
              owner = "sweid4keycloak";
              repo = "bankid4keycloak";
              rev = "v24.0.0";
              sha256 = "sha256-20mc0qfo2B2KyXUbLfc+bSvvaqBcMls0J1JGGSXIfFw=";
            };

            installPhase = ''
              mkdir -p $out
              cp -r $src/src/main/resources/theme-resources/* $out/
            '';
          };
        };

        settings = {
          health-enabled = true;
          hostname = "";
          #hostname = domain;
          #hostname-admin = domain;
          hostname-debug = true;
          hostname-strict = false;
          hostname-strict-backchannel = false;
          http-enabled = false;
          https-port = httpsPort;
          log = "console";
          log-level = "trace";
          metrics-enabled = true;
          proxy-headers = "xforwarded";
        };
      };
      nixpkgs.pkgs = hostPkgs;
      system.stateVersion = "23.11";
    };
  };

  # Host configuration
  services.nginx = {
    package = pkgs.angieQuic;
    recommendedBrotliSettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;
    recommendedZstdSettings = true;
    recommendedProxySettings = true;
  };
  services.nginx.virtualHosts.${alias} = {
    serverAliases = [ "bankid.${topDomain}" ];
    locations."/" = {
      proxyWebsockets = true;
      proxyPass = "https://127.0.0.1:${toString httpsPort}";
    };
    quic = true;
    forceSSL = true;
    useACMEHost = alias;
  };
  security.acme.certs.auth = {
    group = "nginx";
    inherit domain;
    extraDomainNames = [ "bankid.${topDomain}" ];
  };
  networking.hosts = {
    "127.0.0.1" = [
      "bankid.${topDomain}"
      domain
    ];
  };
}
