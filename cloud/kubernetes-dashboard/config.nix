{ config, lib, pkgs, ... }:
let
  kubernetes-dashboard-chart = config.kv.downloadHelmChart {
    repo = "https://kubernetes.github.io/dashboard";
    chart = "kubernetes-dashboard";
    version = "7.10.1";
    chartHash = "sha256-tUKiaz3zqBdrC/HIUFoiI4TWd1UEAUct1ib9Ohk3pB8=";
  };
in
{
  imports = [
    ../nix
  ];

  config = {
    state = "kubernetes-dashboard";
    remoteStates = [ "stage1" ];
    locals.chartParentPath  = toString kubernetes-dashboard-chart;
  };
}
