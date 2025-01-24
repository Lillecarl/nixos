{ config, ... }:
{
  imports = [
    ../nix
  ];

  config = {
    state = "coredns";
    remoteStates = [ ];
    locals.chartParentPath = toString (
      config.kv.downloadHelmChart {
        repo = "https://coredns.github.io/helm";
        chart = "coredns";
        version = "1.37.0";
        chartHash = "sha256-V1492bMu4TzGxk02R39nlZjpZyVei198CI6ZDzk72t0=";
      }
    );
  };
}
