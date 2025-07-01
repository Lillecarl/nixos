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
        default = false;
        description = "Whether to enable ${modName}.";
      };
    };
  };
  config = {
    # Require containerd when we use our own one.
    systemd.services.k3s.requires = [ "containerd.service" ];
    services.k3s = {
      enable = cfg.enable;
      clusterInit = true;
      tokenFile = pkgs.writeText "k3s-token" "iwky4e.igh93hlw8mbf6dqt";

      extraFlags = [
        "--container-runtime-endpoint /run/containerd/containerd.sock"
        "--cluster-cidr 10.32.0.0/16"
        "--service-cidr 10.33.0.0/16"
        "--cluster-domain k3s.lillecarl.com"
        "--disable=traefik" # We use nginx
        "--disable=coredns" # We deploy ourselves
        "--disable-helm-controller" # We don't use Helm like this
        "--disable-kube-proxy" # Cilium
        "--flannel-backend=none" # Cilium
        "--disable-network-policy" # Cilium
        "--disable=servicelb" # Cilium
        # Make Hetzner Controller happy
        "--kubelet-arg=provider-id=hcloud://66552508" # Make this an option
        # OIDC with Keycloak
        "--kube-apiserver-arg=oidc-issuer-url=https://keycloak.lillecarl.com/realms/master"
        "--kube-apiserver-arg=oidc-client-id=kubernetes"
        "--kube-apiserver-arg=oidc-username-claim=sub" # usename is less fluid
        "--kube-apiserver-arg=oidc-groups-claim=groups"
      ];

      role = "server";
    };
    virtualisation.containerd = {
      enable = true;
      settings = {
        plugins =
          let
            cniConfig = {
              # The NixOS module wants to set th
              bin_dir = lib.mkForce "/opt/cni/bin";
              bin_dirs = [ "/opt/cni/bin" ];
              conf_dir = "/etc/cni/net.d";
            };
          in
          {
            "io.containerd.cri.v1.runtime".cni = cniConfig;
            "io.containerd.grpc.v1.cri" = {
              cni = cniConfig;
              containerd.runtimes.runc.options.SystemdCgroup = true;
            };
          };
      };
    };
    environment.sessionVariables = lib.mkIf cfg.enable {
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
