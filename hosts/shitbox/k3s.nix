{
  pkgs,
  lib,
  config,
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
  config = lib.mkIf cfg.enable {
    services.k3s = {
      enable = true;
      package = pkgs.k3s_1_33;
      # Use etcd instead of SQLite
      clusterInit = true;
      role = "server";

      extraFlags = [
        # Networking
        "--node-ip=192.168.88.2"
        "--cluster-cidr=10.55.0.0/16"
        "--service-cidr=10.56.0.0/16"
        "--cluster-domain=k8s.shitbox.lillecarl.com"
        # Disable k3s manifest deployment
        "--disable=traefik" # We use nginx
        # "--disable=coredns" # We deploy ourselves
        # "--disable=local-storage" # Deploy ourselves
        "--disable=metrics-server" # Deploy ourselves
        # Disable k3s features
        "--disable-helm-controller" # We don't use Helm like this
      ];

    };
    boot.kernel.sysctl = {
      # virtualisation.lxd.recommendedSysctlSettings
      "fs.inotify.max_queued_events" = 1048576;
      "fs.inotify.max_user_instances" = 1048576;
      "fs.inotify.max_user_watches" = 1048576;
      "vm.max_map_count" = 262144; # TODO: Default vm.max_map_count has been increased system-wide
      "kernel.dmesg_restrict" = 1;
      "net.ipv4.neigh.default.gc_thresh3" = 8192;
      "net.ipv6.neigh.default.gc_thresh3" = 8192;
      "kernel.keys.maxkeys" = 2000;
      # IPv6 stuff
      "net.ipv6.conf.all.accept_ra" = 2;
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
