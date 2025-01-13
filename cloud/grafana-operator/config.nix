{ config, lib, pkgs, ... }:
let
  grafana-operator-chart = config.kv.downloadHelmChart {
    repo = "https://grafana.github.io/helm-charts";
    chart = "grafana-operator";
    version = "5.15.1";
    chartHash = "sha256-5908dbNkvsdurbcwVGrEJlpYYTG3RTapul7lP+Dszm4=";
  };
in
{
  imports = [
    ../nix
  ];

  config = {
    state = "grafana-operator";
    remoteStates = [ "stage1" ];
    locals.chartParentPath  = toString grafana-operator-chart;
  };
}
