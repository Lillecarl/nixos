{ pkgs, ... }:
{
  virtualisation.containerd.rootless = {
    enable = true;
    nixSnapshotterIntegration = true;
  };

  services.nix-snapshotter.rootless = {
    enable = true;
  };

  home.packages = [ pkgs.nerdctl ];
}
