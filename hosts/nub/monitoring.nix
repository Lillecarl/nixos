{
  pkgs,
  config,
  lib,
  ...
}:
let
  hostname = config.networking.hostName;
  monitordbpath = "/var/lib/grafana/data/monitoring.sqlite3";
  domain = "grafana.${hostname}.lillecarl.com";
  certdir = config.security.acme.certs.${hostname}.directory;

  script = pkgs.writers.writePython3Bin "pymonitoring" {
    libraries = with pkgs.python3.pkgs; [
      plumbum
      psutil
    ];
    flakeIgnore = [
      "E501" # Line too long
    ];
  } ../../scripts/monitoring.py;
in
{
  users.users.grafana = {
    extraGroups = [ config.security.acme.certs.${hostname}.group ];
  };

  services = {
    grafana = {
      enable = true;
      declarativePlugins = with pkgs.grafanaPlugins; [
        frser-sqlite-datasource
      ];

      provision = {
        datasources.settings.datasources = [
          {
            name = "SQLite";
            type = "frser-sqlite-datasource";
            access = "proxy";
            isDefault = true;
            editable = false;
            jsonData = {
              path = monitordbpath;
            };
          }
        ];
      };

      settings = {
        server = {
          inherit domain;
          http_addr = "127.0.0.1";
          http_port = 3000;
          protocol = "https";
          cert_file = "${certdir}/fullchain.pem";
          cert_key = "${certdir}/key.pem";
        };
      };
    };

    nginx = {
      enable = true;

      virtualHosts.${domain} = {
        locations."/" = {
          recommendedProxySettings = true;
          proxyPass = "https://${config.services.grafana.settings.server.http_addr}:${toString config.services.grafana.settings.server.http_port}";
          proxyWebsockets = true;
        };
        forceSSL = true;
        useACMEHost = config.networking.hostName;
      };
    };
  };

  systemd.services.pymonitoring = {
    wantedBy = [ "multi-user.target" ];

    path = with pkgs; [
      msr-tools # Read Manufacturer Specific Registers
      lm_sensors # Read systems sensors
    ];

    script = ''
      # Make sure database exists ahead of time
      ${pkgs.coreutils-full}/bin/touch ${monitordbpath}
      # Make sure database is readable by grafana (Monitoring system runs
      # as root to gain access to MSR and such, so we can read and write either way)
      ${pkgs.coreutils-full}/bin/chown grafana:grafana ${monitordbpath}

      ${lib.getExe script}
    '';
  };

  networking.hosts = {
    "127.0.0.1" = [ domain ];
  };
}
