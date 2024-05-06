{ pkgs, ... }:
{
  services.k3s = {
    enable = true;
    setKubeConfig = true;
  };

  virtualisation.containerd = {
    enable = true;
    k3sIntegration = true;
    nixSnapshotterIntegration = true;
  };

  services.nix-snapshotter = {
    enable = true;
  };

  environment.systemPackages = [
    pkgs.k3s
    pkgs.nerdctl
    pkgs.containerd
    pkgs.cri-tools
    pkgs.kubectl
    pkgs.nix-snapshotter
  ];

  networking.firewall.allowedTCPPorts = [
    6443 # k3s: required so that pods can reach the API server (running on port 6443 by default)
    # 2379 # k3s, etcd clients: required if using a "High Availability Embedded etcd" configuration
    # 2380 # k3s, etcd peers: required if using a "High Availability Embedded etcd" configuration
  ];

  networking.firewall.allowedUDPPorts = [
    # 8472 # k3s, flannel: required if using multi-node for inter-node networking
  ];
}
