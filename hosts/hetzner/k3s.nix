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
    virtualisation.containerd = {
      enable = false;
      settings = {
        # root = "/var/lib/rancher/k3s/agent/containerd";
        state = "/run/containerd";
        grpc.address = "/run/containerd/containerd.sock";
        plugins = {
          "io.containerd.internal.v1.opt".path = "/var/lib/rancher/k3s/agent/containerd";
          "io.containerd.grpc.v1.cri" = {
            stream_server_address = "127.0.0.1";
            stream_server_port = "10010";
          };
          "io.containerd.cri.v1.runtime" = {
            enable_selinux = false;
            enable_unprivileged_ports = true;
            enable_unprivileged_icmp = true;
            device_ownership_from_security_context = false;
          };
          "io.containerd.cri.v1.images" = {
            snapshotter = "overlayfs";
            disable_snapshot_annotations = true;
          };
          "io.containerd.cri.v1.images'.pinned_images".sandbox = "rancher/mirrored-pause:3.6";
          "io.containerd.cri.v1.runtime'.containerd.runtimes.runc".runtime_type = "io.containerd.runc.v2";
          "io.containerd.cri.v1.runtime'.containerd.runtimes.runc.options".SystemdCgroup = true;
          "io.containerd.cri.v1.runtime'.containerd.runtimes.runhcs-wcow-process".runtime_type =
            "io.containerd.runhcs.v1";
          "io.containerd.cri.v1.images'.registry".config_path =
            "/var/lib/rancher/k3s/agent/etc/containerd/certs.d";
        };
      };
    };
    services.k3s = {
      enable = cfg.enable;

      extraFlags = [
        "--enable-pprof"
        "--debug"
        "--cluster-cidr 10.42.0.0/16"
        "--service-cidr 10.43.0.0/16"
        "--cluster-domain k8s.lillecarl.com"
        "--node-ip ${config.lib.hetzAttrs.v4}"
        # "--node-external-ip ${config.lib.hetzAttrs.v4}"
        # "--embedded-registry" # Allow local mirroring
        "--disable=traefik" # We use nginx
        "--disable=coredns" # We deploy ourselves
        "--disable-helm-controller" # We don't use Helm like this
        "--disable-kube-proxy" # Cilium
        "--flannel-backend=none" # Cilium
        "--disable-network-policy" # Cilium
        "--disable=servicelb" # Cilium
        # Make Hetzner Controller happy
        "--kubelet-arg=provider-id=hcloud://${config.lib.hetzAttrs.id}"
        # OIDC with Keycloak
        "--kube-apiserver-arg=oidc-issuer-url=https://keycloak.lillecarl.com/realms/master"
        "--kube-apiserver-arg=oidc-client-id=kubernetes"
        "--kube-apiserver-arg=oidc-username-claim=sub" # usename is less fluid
        "--kube-apiserver-arg=oidc-groups-claim=groups"
        # "--container-runtime-endpoint unix:///run/containerd/containerd.sock"
      ];

      role = config.ps.labels.k8s_role;
    };
    environment.variables = lib.mkIf cfg.enable {
      # CONTAINERD_ADDRESS = "/run/containerd/containerd.sock";
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
