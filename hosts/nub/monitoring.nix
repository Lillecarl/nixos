{ pkgs
, config
, ...
}:
let
  plumpy = pkgs.python3.withPackages (ps: with ps; [
    plumbum
    psutil
  ]);
  pyscript = ../../scripts/monitoring.py;
  monitordbpath = "/var/lib/grafana/data/monitoring.sqlite3";
  domain = "grafana.127.lillecarl.com";
  certdir = config.security.acme.certs.grafana.directory;
in
{
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
          http_addr = "127.0.0.1";
          http_port = 3000;
          inherit domain;
          root_url = "https://${domain}/";
          serve_from_sub_path = true;
        };
      };
    };

    nginx = {
      enable = true;
    };

    nginx.virtualHosts.${domain} = {
      locations."/" = {
        recommendedProxySettings = true;
        proxyPass = "http://${toString config.services.grafana.settings.server.http_addr}:${toString config.services.grafana.settings.server.http_port}";
        proxyWebsockets = true;
      };
      forceSSL = true;
      sslCertificate = "${certdir}/fullchain.pem";
      sslCertificateKey = "${certdir}/key.pem";
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

      ${plumpy}/bin/python3 -u ${pyscript}
    '';
  };


  security.acme.certs.grafana = {
    inherit domain;
    inherit (config.services.nginx) group;
  };

  networking.hosts = {
    "127.0.0.1" = [ domain ];
  };
}
