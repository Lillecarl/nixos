{
  lib,
  config,
  pkgs,
  ...
}:
let
  modName = "k3s";
  cfg = config.ps.${modName};
in
{
  options.ps = {
    ${modName} = {
      enable = lib.mkOption {
        default = true;
        description = "Whether to enable ${modName}.";
      };
    };
  };
  config = {
    ps.k3s.enable = !((config.ps.labels.anywhere or "no") == "yes");
    services.k3s = {
      enable = cfg.enable;

      extraFlags = [
        "--disable=traefik"
        "--disable=coredns"

        # "--disable-kube-proxy"

        "--flannel-backend=none"
        "--disable-network-policy"

        # "--no-deploy servicelb"
        # "--disable-cloud-controller"
        # "--kubelet-arg=cloud-provider=external"
        "--kubelet-arg=provider-id=hcloud://${config.lib.hetzAttrs.id}"

        "--kube-apiserver-arg=oidc-issuer-url=https://keycloak.lillecarl.com/realms/master"
        "--kube-apiserver-arg=oidc-client-id=kubernetes"
        "--kube-apiserver-arg=oidc-username-claim=sub" # usename is less fluid
        "--kube-apiserver-arg=oidc-groups-claim=groups"
      ];

      role = config.ps.labels.k8s_role;
    };
    environment.variables = lib.mkIf cfg.enable {
      CONTAINERD_ADDRESS = "/run/k3s/containerd/containerd.sock";
      CONTAINERD_NAMESPACE = "k8s.io";
    };
    environment.systemPackages = [
      pkgs.cilium-cli
    ];
    boot.kernel.sysctl = { # virtualisation.lxd.recommendedSysctlSettings
      "fs.inotify.max_queued_events" = 1048576;
      "fs.inotify.max_user_instances" = 1048576;
      "fs.inotify.max_user_watches" = 1048576;
      "vm.max_map_count" = 262144;
      "kernel.dmesg_restrict" = 1;
      "net.ipv4.neigh.default.gc_thresh3" = 8192;
      "net.ipv6.neigh.default.gc_thresh3" = 8192;
      "kernel.keys.maxkeys" = 2000;
    };
  };
}
