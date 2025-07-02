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
      package = lib.mkPackageOption pkgs "k3s" { };
      clusterCidr = lib.mkOption {
        type = lib.types.str;
      };
      serviceCidr = lib.mkOption {
        type = lib.types.str;
      };
      nodeIPs = lib.mkOption {
        type = lib.types.listOf lib.types.str;
      };
      externalNodeIPs = lib.mkOption {
        type = lib.types.listOf lib.types.str;
      };
      clusterDomain = lib.mkOption {
        type = lib.types.str;
      };
    };
  };
  config = {
    # Require containerd when we use our own one.
    systemd.services.k3s.requires = [ "containerd.service" ];
    services.k3s = {
      enable = cfg.enable;
      clusterInit = true;
      token = "Cardstock9.Maximum.Sage";

      extraFlags = [
        "--container-runtime-endpoint /run/containerd/containerd.sock"
        # Networking
        # "--node-external-ip=${lib.concatStringsSep "," cfg.externalNodeIPs}"
        "--node-ip=${lib.concatStringsSep "," cfg.nodeIPs}"
        "--node-name=${config.networking.hostName}"
        "--cluster-cidr ${cfg.clusterCidr},fd8f:9936:bf27::/64"
        "--service-cidr ${cfg.serviceCidr},fd8f:9936:bf28::/108"
        "--cluster-domain ${cfg.clusterDomain}"
        # Disable k3s manifest deployment
        "--disable=traefik" # We use nginx
        "--disable=coredns" # We deploy ourselves
        "--disable=local-storage" # Deploy ourselves
        "--disable=metrics-server" # Deploy ourselves
        # Disable k3s features
        "--disable-helm-controller" # We don't use Helm like this
        "--disable-kube-proxy" # Cilium
        "--flannel-backend=none" # Cilium
        "--disable-network-policy" # Cilium
        # "--disable=servicelb" # Cilium
        # # Make Hetzner Controller happy
        # "--kubelet-arg=provider-id=hcloud://66552508" # Make this an option
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
      # configFile = "/etc/containerd/config.toml";
      settings = {
        plugins =
          let
            cniConfig = {
              # The NixOS module wants to set th
              bin_dir = lib.mkForce "/opt/cni/bin";
              # bin_dir = lib.mkForce "";
              # bin_dirs = [
              #   "/opt/cni/bin"
              #   "${pkgs.cni-plugins}/bin"
              # ];
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
      CONTAINERD_ADDRESS = "/run/containerd/containerd.sock";
      CONTAINERD_NAMESPACE = "k8s.io";
    };
    environment.systemPackages = [
      pkgs.cilium-cli
    ];
    # Allow remote access to k3s
    networking.firewall.allowedTCPPorts = [ 6443 ];
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
    system.activationScripts.cniCopy = {
      text = # bash
        ''
          mkdir -p /opt/cni/bin/
          cp -r ${pkgs.cni-plugins}/bin/. /opt/cni/bin/.
        '';
    };
    environment.etc."containerd/config.toml".text = # toml
      ''
        version = 3
        root = "/var/lib/containerd"
        state = "/run/containerd"
        temp = ""
        disabled_plugins = []
        required_plugins = []
        oom_score = 0
        imports = []

        [grpc]
          address = "/run/containerd/containerd.sock"
          tcp_address = ""
          tcp_tls_ca = ""
          tcp_tls_cert = ""
          tcp_tls_key = ""
          uid = 0
          gid = 0
          max_recv_message_size = 16777216
          max_send_message_size = 16777216

        [ttrpc]
          address = ""
          uid = 0
          gid = 0

        [debug]
          address = ""
          uid = 0
          gid = 0
          level = ""
          format = ""

        [metrics]
          address = ""
          grpc_histogram = false

        [plugins]
          [plugins."io.containerd.cri.v1.images"]
            snapshotter = "overlayfs"
            disable_snapshot_annotations = true
            discard_unpacked_layers = false
            max_concurrent_downloads = 3
            concurrent_layer_fetch_buffer = 0
            image_pull_progress_timeout = "5m0s"
            image_pull_with_sync_fs = false
            stats_collect_period = 10
            use_local_image_pull = false

            [plugins."io.containerd.cri.v1.images".pinned_images]
              sandbox = "registry.k8s.io/pause:3.10"

            [plugins."io.containerd.cri.v1.images".registry]
              config_path = ""

            [plugins."io.containerd.cri.v1.images".image_decryption]
              key_model = "node"

          [plugins."io.containerd.cri.v1.runtime"]
            enable_selinux = false
            selinux_category_range = 1024
            max_container_log_line_size = 16384
            disable_apparmor = false
            restrict_oom_score_adj = false
            disable_proc_mount = false
            unset_seccomp_profile = ""
            tolerate_missing_hugetlb_controller = true
            disable_hugetlb_controller = true
            device_ownership_from_security_context = false
            ignore_image_defined_volumes = false
            netns_mounts_under_state_dir = false
            enable_unprivileged_ports = true
            enable_unprivileged_icmp = true
            enable_cdi = true
            cdi_spec_dirs = ["/etc/cdi", "/var/run/cdi"]
            drain_exec_sync_io_timeout = "0s"
            ignore_deprecation_warnings = []

            [plugins."io.containerd.cri.v1.runtime".containerd]
              default_runtime_name = "runc"
              ignore_blockio_not_enabled_errors = false
              ignore_rdt_not_enabled_errors = false

              [plugins."io.containerd.cri.v1.runtime".containerd.runtimes]
                [plugins."io.containerd.cri.v1.runtime".containerd.runtimes.runc]
                  runtime_type = "io.containerd.runc.v2"
                  runtime_path = ""
                  pod_annotations = []
                  container_annotations = []
                  privileged_without_host_devices = false
                  privileged_without_host_devices_all_devices_allowed = false
                  cgroup_writable = false
                  base_runtime_spec = ""
                  cni_conf_dir = ""
                  cni_max_conf_num = 0
                  snapshotter = ""
                  sandboxer = "podsandbox"
                  io_type = ""

                  [plugins."io.containerd.cri.v1.runtime".containerd.runtimes.runc.options]
                    BinaryName = ""
                    CriuImagePath = ""
                    CriuWorkPath = ""
                    IoGid = 0
                    IoUid = 0
                    NoNewKeyring = false
                    Root = ""
                    ShimCgroup = ""
                    SystemdCgroup = true

            [plugins."io.containerd.cri.v1.runtime".cni]
              bin_dirs = ["/opt/cni/bin","${pkgs.cni-plugins}/bin"]
              conf_dir = "/etc/cni/net.d"
              max_conf_num = 1
              setup_serially = false
              conf_template = ""
              ip_pref = ""
              use_internal_loopback = false

          [plugins."io.containerd.differ.v1.erofs"]
            mkfs_options = []

          [plugins."io.containerd.gc.v1.scheduler"]
            pause_threshold = 0.02
            deletion_threshold = 0
            mutation_threshold = 100
            schedule_delay = "0s"
            startup_delay = "100ms"

          [plugins."io.containerd.grpc.v1.cri"]
            disable_tcp_service = true
            stream_server_address = "127.0.0.1"
            stream_server_port = "0"
            stream_idle_timeout = "4h0m0s"
            enable_tls_streaming = false

            [plugins."io.containerd.grpc.v1.cri".x509_key_pair_streaming]
              tls_cert_file = ""
              tls_key_file = ""

          [plugins."io.containerd.image-verifier.v1.bindir"]
            bin_dir = "/opt/containerd/image-verifier/bin"
            max_verifiers = 10
            per_verifier_timeout = "10s"

          [plugins."io.containerd.internal.v1.opt"]
            path = "/opt/containerd"

          [plugins."io.containerd.internal.v1.tracing"]

          [plugins."io.containerd.metadata.v1.bolt"]
            content_sharing_policy = "shared"
            no_sync = false

          [plugins."io.containerd.monitor.container.v1.restart"]
            interval = "10s"

          [plugins."io.containerd.monitor.task.v1.cgroups"]
            no_prometheus = false

          [plugins."io.containerd.nri.v1.nri"]
            disable = false
            socket_path = "/var/run/nri/nri.sock"
            plugin_path = "/opt/nri/plugins"
            plugin_config_path = "/etc/nri/conf.d"
            plugin_registration_timeout = "5s"
            plugin_request_timeout = "2s"
            disable_connections = false

          [plugins."io.containerd.runtime.v2.task"]
            platforms = ["linux/amd64"]

          [plugins."io.containerd.service.v1.diff-service"]
            default = ["walking"]
            sync_fs = false

          [plugins."io.containerd.service.v1.tasks-service"]
            blockio_config_file = ""
            rdt_config_file = ""

          [plugins."io.containerd.shim.v1.manager"]
            env = []

          [plugins."io.containerd.snapshotter.v1.blockfile"]
            root_path = ""
            scratch_file = ""
            fs_type = ""
            mount_options = []
            recreate_scratch = false

          [plugins."io.containerd.snapshotter.v1.btrfs"]
            root_path = ""

          [plugins."io.containerd.snapshotter.v1.devmapper"]
            root_path = ""
            pool_name = ""
            base_image_size = ""
            async_remove = false
            discard_blocks = false
            fs_type = ""
            fs_options = ""

          [plugins."io.containerd.snapshotter.v1.erofs"]
            root_path = ""
            ovl_mount_options = []
            enable_fsverity = false

          [plugins."io.containerd.snapshotter.v1.native"]
            root_path = ""

          [plugins."io.containerd.snapshotter.v1.overlayfs"]
            root_path = ""
            upperdir_label = false
            sync_remove = false
            slow_chown = false
            mount_options = []

          [plugins."io.containerd.snapshotter.v1.zfs"]
            root_path = ""

          [plugins."io.containerd.tracing.processor.v1.otlp"]

          [plugins."io.containerd.transfer.v1.local"]
            max_concurrent_downloads = 3
            concurrent_layer_fetch_buffer = 0
            max_concurrent_uploaded_layers = 3
            check_platform_supported = false
            config_path = ""

        [cgroup]
          path = ""

        [timeouts]
          "io.containerd.timeout.bolt.open" = "0s"
          "io.containerd.timeout.cri.defercleanup" = "1m0s"
          "io.containerd.timeout.metrics.shimstats" = "2s"
          "io.containerd.timeout.shim.cleanup" = "5s"
          "io.containerd.timeout.shim.load" = "5s"
          "io.containerd.timeout.shim.shutdown" = "3s"
          "io.containerd.timeout.task.state" = "2s"

        [stream_processors]
          [stream_processors."io.containerd.ocicrypt.decoder.v1.tar"]
            accepts = ["application/vnd.oci.image.layer.v1.tar+encrypted"]
            returns = "application/vnd.oci.image.layer.v1.tar"
            path = "ctd-decoder"
            args = ["--decryption-keys-path", "/etc/containerd/ocicrypt/keys"]
            env = ["OCICRYPT_KEYPROVIDER_CONFIG=/etc/containerd/ocicrypt/ocicrypt_keyprovider.conf"]

          [stream_processors."io.containerd.ocicrypt.decoder.v1.tar.gzip"]
            accepts = ["application/vnd.oci.image.layer.v1.tar+gzip+encrypted"]
            returns = "application/vnd.oci.image.layer.v1.tar+gzip"
            path = "ctd-decoder"
            args = ["--decryption-keys-path", "/etc/containerd/ocicrypt/keys"]
            env = ["OCICRYPT_KEYPROVIDER_CONFIG=/etc/containerd/ocicrypt/ocicrypt_keyprovider.conf"]    '';
  };
}
