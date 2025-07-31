{ config, lib, pkgs, ... }:
let
  victoria-metrics-operator-chart = config.kv.downloadHelmChart {
    repo = "https://victoriametrics.github.io/helm-charts/";
    chart = "victoria-metrics-operator";
    version = "0.40.4";
    chartHash = "sha256-9XGt+xdBzE3H+PpLPxNG7xWxEqk1r3Vz4BxeCCSaYtI=";
  };
in
{
  imports = [
    ../nix
  ];

  config = {
    state = "victoriametrics-operator";
    remoteStates = [ "stage1" ];
    locals.chartParentPath  = toString victoria-metrics-operator-chart;
  };
}
