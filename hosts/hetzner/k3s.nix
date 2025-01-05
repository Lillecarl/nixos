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
        "--cluster-cidr 10.42.0.0/16"
        "--service-cidr 10.43.0.0/16"
        "--cluster-domain k8s.lillecarl.com"
        "--embedded-registry" # Allow local mirroring
        "--disable=traefik" # We use nginx
        "--disable=coredns" # We deploy ourselves
        "--disable-helm-controller" # We don't use Helm like this
        "--disable-kube-proxy" # Cilium
        "--flannel-backend=none" # Cilium
        "--disable-network-policy" # Cilium
        # Make Hetzner Controller happy
        "--kubelet-arg=provider-id=hcloud://${config.lib.hetzAttrs.id}"
        # OIDC with Keycloak
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
    boot.kernel.sysctl = {
      # virtualisation.lxd.recommendedSysctlSettings
      "fs.inotify.max_queued_events" = 1048576;
      "fs.inotify.max_user_instances" = 1048576;
      "fs.inotify.max_user_watches" = 1048576;
      "vm.max_map_count" = 262144;
      "kernel.dmesg_restrict" = 1;
      "net.ipv4.neigh.default.gc_thresh3" = 8192;
      "net.ipv6.neigh.default.gc_thresh3" = 8192;
      "kernel.keys.maxkeys" = 2000;
    };
    # Load IPv6 modules requred by Cilium
    boot.kernelModules = [
      "ip6_tables"
      "ip6table_mangle"
      "ip6table_raw"
      "ip6table_filter"
    ];
  };
}
