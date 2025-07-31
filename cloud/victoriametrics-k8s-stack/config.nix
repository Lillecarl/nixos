{ config, lib, pkgs, ... }:
let
  victoria-metrics-k8s-stack-chart = config.kv.downloadHelmChart {
    repo = "https://victoriametrics.github.io/helm-charts/";
    chart = "victoria-metrics-k8s-stack";
    version = "0.33.3";
    chartHash = "sha256-+j5y66e95oysbyvdt/Oj0zH1+YNjcy1maLc/JFKBQ4U=";
  };
in
{
  imports = [
    ../nix
  ];

  config = {
    state = "victoriametrics-k8s-stack";
    remoteStates = [ "stage1" ];
    locals.chartParentPath  = toString victoria-metrics-k8s-stack-chart;
  };
}
