{ pkgs
, ...
}:
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
}
