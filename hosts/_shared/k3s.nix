{ pkgs, config, ... }:
{
  services.k3s = {
    enable = true;
    package = pkgs.k3s_1_29;
    #setKubeConfig = true;
    #extraFlags = toString [
    #  "--snapshotter=btrfs --container-runtime-endpoint unix:///run/containerd/containerd.sock"
    #];
  };

  virtualisation.containerd = {
    enable = false;
    settings =
      let
        fullCNIPlugins = pkgs.buildEnv {
          name = "full-cni";
          paths = with pkgs;[
            cni-plugins
            cni-plugin-flannel
          ];
        };
      in
      {
        plugins."io.containerd.grpc.v1.cri".cni = {
          bin_dir = "${fullCNIPlugins}/bin";
          conf_dir = "/var/lib/rancher/k3s/agent/etc/cni/net.d/";
        };
        # Optionally set private registry credentials here instead of using /etc/rancher/k3s/registries.yaml
        # plugins."io.containerd.grpc.v1.cri".registry.configs."registry.example.com".auth = {
        #  username = "";
        #  password = "";
        # };
      };
  };

  #services.nix-snapshotter = {
  #  enable = true;
  #};

  environment.systemPackages = [
    #pkgs.nix-snapshotter
    config.services.k3s.package
    pkgs.containerd
    pkgs.cri-tools
    pkgs.kubectl
    pkgs.nerdctl
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
