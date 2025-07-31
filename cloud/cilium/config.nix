{ config, lib, pkgs, ... }:
let
  cilium-chart = config.kv.downloadHelmChart {
    repo = "https://helm.cilium.io";
    chart = "cilium";
    version = "1.16.6";
    chartHash = "sha256-dSxYz+Rnx859Z6hcgxTAq4g8cnemwGVO2KIUk2ig5Nk=";
  };
in
{
  imports = [
    ../nix
  ];

  config = {
    state = "cilium";
    remoteStates = [ ];
    locals.chartParentPath  = toString cilium-chart;
  };
}
