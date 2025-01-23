{ config, lib, pkgs, ... }:
let
  ingress-nginx-chart = config.kv.downloadHelmChart {
    repo = "https://kubernetes.github.io/ingress-nginx";
    chart = "ingress-nginx";
    version = "4.12.0";
    chartHash = "sha256-BwGi7t+Jdtstzy01ggJNxyAp13wTcfkEumAjdsCLbPk=";
  };
in
{
  imports = [
    ../nix
  ];

  config = {
    state = "nginx";
    remoteStates = [ ];
    locals.chartParentPath  = toString ingress-nginx-chart;
  };
}
