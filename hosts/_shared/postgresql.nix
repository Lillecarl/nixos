{ lib
, config
, pkgs
, ...
}:
let
  ourPython3 = pkgs.python3.withPackages (ps: with ps; [
    numpy
  ]);
in
{
  services.postgresql = {
    enable = true;
    enableTCPIP = false;

    package = pkgs.postgresql_16.override {
      pythonSupport = true;
      inherit (pkgs) python3;
    };

    extraPlugins = with config.services.postgresql.package.pkgs; [
      (pkgs.pllua_jit.override {
        postgresql = config.services.postgresql.package;
      })
      (pkgs.plprql.override {
        postgresql = config.services.postgresql.package;
      })
      (pkgs.pg_graphql.override {
        postgresql = config.services.postgresql.package;
      })
      (pkgs.pg_jsonschema.override {
        postgresql = config.services.postgresql.package;
      })
      (pkgs.pg_analytics.override {
        postgresql = config.services.postgresql.package;
      })
      (pkgs.pgmq.override {
        postgresql = config.services.postgresql.package;
      })
      (postgis.overrideAttrs (oldAttrs: {
        doCheck = false; # postgis tests take ages
        doInstallCheck = false;
      }))
      pg_cron
      pg_ivm
      pg_safeupdate
      pg_similarity
      pg_squeeze
      pgrouting
      pgsql-http
      plpgsql_check
      plv8
      system_stats
      timescaledb
      timescaledb_toolkit
    ];

    settings = {
      shared_preload_libraries = [
        "pg_cron"
        "pg_squeeze"
        "pg_stat_statements"
        "plpgsql"
        "plpgsql_check"
        "safeupdate"
        "timescaledb"
      ];
    };

    ensureUsers = [
      {
        name = "lillecarl";
        ensureDBOwnership = true;
        ensureClauses.superuser = true;
      }
      {
        name = "keycloak";
        ensureDBOwnership = true;
      }
    ];
    ensureDatabases = [
      "lillecarl"
      "keycloak"
    ];

    authentication = ''
      host    all             all             0.0.0.0/0               pam     pamservice=postgresql
    '';
  };

  # Enable pgAdmin
  services.pgadmin = {
    enable = true;

    initialEmail = "user@pgadmin.com";
    initialPasswordFile = "${pkgs.writeText "pgadmin-password" "changeme"}";
    openFirewall = false;

    settings = {
      #SERVER_MODE = lib.mkForce false;
      #DATA_DIR = "/var/lib/pgadmin";
      #LOG_FILE = "/var/log/pgadmin/pg.log";
    };
  };


  systemd = {
    services = {
      # Add python packaes to postgres through PYTHONPATH
      postgresql.environment.PYTHONPATH = builtins.concatStringsSep ":" [
        "${ourPython3}/lib/${ourPython3.libPrefix}"
        "${ourPython3}/lib/${ourPython3.libPrefix}/site-packages"
      ];

      # Only run pgAdmin when it's required
      pgadmin = {
        wantedBy = lib.mkForce [ ];
        after = lib.mkForce [ ];
        requires = lib.mkForce [ ];
        unitConfig = {
          StopWhenUnneeded = true;
        };
      };
      proxy-to-pgadmin = {
        requires = [ "pgadmin.service" "proxy-to-pgadmin.socket" ];
        after = [ "pgadmin.service" "proxy-to-pgadmin.socket" ];

        unitConfig = {
          JoinsNamespaceOf = "pgadmin.service";
        };

        serviceConfig = {
          Type = "notify";
          ExecStart = "${config.systemd.package}/lib/systemd/systemd-socket-proxyd --exit-idle-time=1h 127.0.0.1:5050";
          PrivateTmp = true;
          PrivateNetwork = true;
        };
      };
    };
    sockets = {
      proxy-to-pgadmin = {
        wantedBy = [ "sockets.target" ];
        listenStreams = [ "127.0.0.1:5051" ];
      };
    };
  };
}
