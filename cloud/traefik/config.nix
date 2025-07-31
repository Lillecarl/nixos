{ config, lib, pkgs, ... }:
let
  traefik-chart = config.kv.downloadHelmChart {
    repo = "https://traefik.github.io/charts";
    chart = "traefik";
    version = "34.1.0";
    chartHash = "sha256-WsHttwYThAqAXXxtu/Yzz1sppMDGZyrM7PrBK03zmJY=";
  };
in
{
  imports = [
    ../nix
  ];

  config = {
    state = "traefik";
    remoteStates = [ ];
    locals.chartParentPath  = toString traefik-chart;
  };
}
