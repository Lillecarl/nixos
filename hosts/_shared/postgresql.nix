{ config
, pkgs
, ...
}:
let
  ourPython3 = pkgs.python3.withPackages (ps: with ps; [
    numpy
  ]);
in
{
  systemd.services.postgresql.environment.PYTHONPATH = builtins.concatStringsSep ":" [
    "${ourPython3}/lib/${ourPython3.libPrefix}"
    "${ourPython3}/lib/${ourPython3.libPrefix}/site-packages"
  ];

  services.postgresql = {
    enable = true;
    enableTCPIP = false;

    package = pkgs.postgresql_16.override {
      pythonSupport = true;
      python3 = pkgs.python3;
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
      pg_cron
      pg_ivm
      pg_safeupdate
      pg_similarity
      pg_squeeze
      pgrouting
      pgsql-http
      plpgsql_check
      plv8
      postgis
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
  };
}
