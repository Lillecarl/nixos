{ pkgs, ... }:
{
  virtualisation.containerd = {
    enable = true;
    nixSnapshotterIntegration = true;
  };

  services.nix-snapshotter = {
    enable = true;
  };

  environment.systemPackages = [ pkgs.nerdctl ];
}
