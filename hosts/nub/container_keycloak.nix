{
  config,
  pkgs,
  self,
  inputs,
  lib,
  ...
}:
let
  alias = "auth";
  topDomain = "lillecarl.com";
  domain = "${alias}.${topDomain}";

  certPath = config.security.acme.certs.${alias}.directory;
  httpsPort = 20443;
  pgport = 5433;
  username = "keycloak";
  dbname = username;
in
if true then
  { }
else
  {
    disabledModules = [
      "services/web-apps/keycloak.nix"
    ];
    imports = [
      "${self}/modules/nixos/keycloak.nix"
    ];

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

      config =
        {
          config,
          pkgs,
          lib,
          hostConfig,
          hostPkgs,
          ...
        }:
        {
          imports = [
            ../_shared/nix.nix
          ];

          environment.systemPackages = [
            pkgs.kitty.terminfo # Terminal acts all weird otherwise
            pkgs.binutils # strings
          ];

          passthru.kc = lib.lists.head (
            lib.filter (x: (x.pname or "") == "keycloak") config.environment.systemPackages
          );

          services.openssh.ports = [ 20022 ];
          users = {
            users.keycloak = {
              isNormalUser = true;
              group = username;
            };
            groups.keycloak = { };
          };
          security.wrappers."kc.sh" =
            let
              envWrap =
                pkgs.writeScript "kc_env_wrap" # bash
                  ''
                    #!/usr/bin/env bash
                    export KC_HOME_DIR="/run/keycloak"
                    export KC_CONF_DIR="/run/keycloak/conf"
                    exec ${config.passthru.kc}/bin/kc.sh "$@"
                  '';
            in
            {
              setuid = true;
              setgid = true;
              owner = username;
              group = username;
              source = "${envWrap}";
            };

          services.postgresql = {
            enable = true;
            settings = {
              port = pgport;
              log_connections = true;
            };
            #identMap = ''
            #  # MAPNAME       SYSTEM-USERNAME   PG-USERNAME
            #  keycloak        keycloak          keycloak
            #'';
            ensureUsers = [
              {
                name = "keycloak";
                ensureDBOwnership = true;
              }
            ];
            ensureDatabases = [ "keycloak" ];
          };

          services.keycloak = {
            enable = true;

            sslCertificate = "${certPath}/fullchain.pem";
            sslCertificateKey = "${certPath}/key.pem";

            database = {
              type = "postgresql";
              port = pgport;
              createLocally = false;

              username = "keycloak";
              passwordFile = "${pkgs.writeText "keycloak-db-password" "lillecarl"}";
            };

            plugins = [
              (pkgs.fetchurl {
                url = "https://github.com/sweid4keycloak/bankid4keycloak/releases/download/v24.0.0/bankid4keycloak-24.0.0.jar";
                sha256 = "sha256:062mvnym9zi6c7ia3jjjpvqk5092pymfnp5wc86r49y8qi7qdrj0";
              })
              (builtins.fetchurl {
                url = "https://github.com/kohlschutter/junixsocket/releases/download/junixsocket-2.9.1/junixsocket-selftest-2.9.1-jar-with-dependencies.jar";
                sha256 = "sha256:0bcj37ccm3dim4zwa8wvb0vak8kcgqc6w5p03rc9d94nci93h3xr";
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
              # I hate Java so much...
              #db-password = lib.mkForce null;
              #db-url = lib.mkForce "jdbc:postgresql://localhost/keycloak?socketFactory=org.newsclub.net.unix.AFUNIXSocketFactory$FactoryArg&socketFactoryArg=/var/run/postgresql/.s.PGSQL.${toString pgport}&sslmode=disable";
              db-url-database = dbname;
              db-url-host = "localhost";
              db-url-port = pgport;
              db-url-properties = "socketFactory=org.newsclub.net.unix.AFUNIXSocketFactory$FactoryArg&socketFactoryArg=/var/run/postgresql/.s.PGSQL.${toString pgport}&sslmode=disable";
              db-username = "keycloak";
              db-password = null;
              #db-url-database = lib.mkForce null;
              #db-url-host = lib.mkForce null;
              #db-url-port = lib.mkForce null;
              #db-url-properties = lib.mkForce null;
              #db-username = lib.mkForce null;
              health-enabled = true;
              hostname = "";
              hostname-debug = true;
              hostname-strict = false;
              #hostname-strict-backchannel = false;
              hostname-backchannel-dynamic = true;
              http-enabled = false;
              https-port = httpsPort;
              log = "console";
              log-level = "info";
              metrics-enabled = true;
              proxy-headers = "xforwarded";
              "quarkus.transaction-manager.enable-recovery" = true;
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
