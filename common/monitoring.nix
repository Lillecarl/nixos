{ pkgs
, ...
}:
let
  plumpy = pkgs.python3.withPackages (ps: with ps; [
    plumbum
    psutil
  ]);
  pyscript = ../monitoring.py;
in
{
  services.grafana = {
    enable = true;
    declarativePlugins = with pkgs.grafanaPlugins; [
      frser-sqlite-datasource
    ];

    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 3000;
        domain = "localhost";
        root_url = "http://localhost/grafana/";
        serve_from_sub_path = true;
      };
    };
  };

  systemd.services.pymonitoring = {
    wantedBy = [ "multi-user.target" ];

    path = with pkgs; [
      msr-tools
      lm_sensors
    ];

    script = ''
      # Make sure database exists ahead of time
      ${pkgs.coreutils}/bin/touch /var/lib/grafana/data/monitoring.sqlite3
      # Make sure database is readable by grafana (Monitoring system runs
      # as root to gain access to MSR and such, so we can read and write either way)
      ${pkgs.coreutils}/bin/chown grafana:grafana /var/lib/grafana/data/monitoring.sqlite3

      ${plumpy}/bin/python3 -u ${pyscript}
    '';
  };
}
