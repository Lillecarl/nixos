{ config, pkgs, ... }:
{
  services.k3s = {
    enable = true;
  };

  environment.systemPackages = [
    pkgs.k3s
    pkgs.kubelogin-oidc
  ];

  virtualisation.containerd = {
    enable = true;
    settings =
      let
        fullCNIPlugins = pkgs.buildEnv {
          name = "full-cni";
          paths = with pkgs;[
            cni-plugins
            cni-plugin-flannel
            multus-cni
          ];
        };
      in
      {
        plugins."io.containerd.grpc.v1.cri".cni = {
          bin_dir = "${fullCNIPlugins}/bin";
          conf_dir = "/var/lib/rancher/k3s/agent/etc/cni/net.d/";
        };
      };
  };
  # TODO describe how to enable zfs snapshotter in containerd
  services.k3s.extraFlags = toString [
    "--container-runtime-endpoint unix:///run/containerd/containerd.sock"
  ];
}
