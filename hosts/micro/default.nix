{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
let
  toYAML =
    input:
    if builtins.typeOf input == "list" then
      lib.concatStringsSep "\n---\n" (map (doc: builtins.toJSON doc) input)
    else if builtins.typeOf input == "set" then
      builtins.toJSON input
    else
      throw "toYAML only supports set and list types";

  initConfig = {
    apiVersion = "kubeadm.k8s.io/v1beta4";
    kind = "InitConfiguration";
    bootstrapTokens = [
      {
        groups = [
          "system:bootstrappers:kubeadm:default-node-token"
        ];
        token = "abcdef.0123456789abcdef";
        ttl = "24h0m0s";
        usages = [
          "signing"
          "authentication"
        ];
      }
    ];
    skipPhases = [
      "addon/kube-proxy"
      "addon/coredns"
    ];
    localAPIEndpoint = {
      advertiseAddress = config.lib.micro.ip4;
      bindPort = 6443;
    };
    nodeRegistration = {
      criSocket = "unix:///var/run/containerd/containerd.sock";
      imagePullPolicy = "IfNotPresent";
      imagePullSerial = true;
      name = config.networking.hostName;
      taints = null;
      ignorePreflightErrors = [
        "Mem"
      ];
      kubeletExtraArgs = lib.mapAttrsToList (name: value: { inherit name value; }) {
        cgroup-driver = "systemd";
      };
    };
    timeouts = {
      controlPlaneComponentHealthCheck = "1m0s";
      discovery = "1m0s";
      etcdAPICall = "1m0s";
      kubeletHealthCheck = "1m0s";
      kubernetesAPICall = "1m0s";
      tlsBootstrap = "1m0s";
      upgradeManifests = "1m0s";
    };
  };

  clusterConfig = {
    apiVersion = "kubeadm.k8s.io/v1beta4";
    kind = "ClusterConfiguration";
    kubernetesVersion = "1.33.4";
    apiServer = { };
    caCertificateValidityPeriod = "87600h0m0s";
    certificateValidityPeriod = "8760h0m0s";
    certificatesDir = "/etc/kubernetes/pki";
    clusterName = "kubernetes";
    controllerManager = { };
    dns = {
      disabled = true;
    };
    proxy = {
      disabled = true;
    };
    scheduler = { };
    encryptionAlgorithm = "RSA-2048";
    etcd = {
      local = {
        dataDir = "/var/lib/etcd";
        extraArgs = lib.mapAttrsToList (name: value: { inherit name value; }) {
          quota-backend-bytes = "${toString (32 * 1024 * 1024)}";
          max-request-bytes = "${toString (2 * 1024 * 1024)}";
          auto-compaction-retention = "1";
          snapshot-count = "1000";
          max-txn-ops = "128";
          heartbeat-interval = "500";
          election-timeout = "2500";
        };
      };
    };
    imageRepository = "registry.k8s.io";
    networking = {
      dnsDomain = "cluster.local";
      serviceSubnet = "10.96.0.0/16";
      podSubnet = "10.97.0.0/16";
    };
  };
  kubeletConfig = {
    apiVersion = "kubelet.config.k8s.io/v1beta1";
    kind = "KubeletConfiguration";
    cgroupDriver = "systemd";
  };
in
{
  imports = [
    inputs.microvm.nixosModules.microvm
    ../k3s/users.nix
    ../k3s/nix.nix
  ];
  config = {
    system.stateVersion = lib.trivial.release;
    boot.kernel.sysctl."net.ipv4.ip_forward" = "1";
    boot.kernel.sysctl."net.ipv6.ip_forward" = "1";

    environment.systemPackages = with pkgs; [
      htop
      kubernetes
      cri-tools
      (
        let
          sudo = "/run/wrappers/bin/sudo";
          fish = lib.getExe pkgs.fish;
          kubeadm = lib.getExe' pkgs.kubernetes "kubeadm";
        in
        pkgs.writeScriptBin "kinit" ''
          #! ${fish}
          ${sudo} -E ${kubeadm} init --config=/etc/kubeadm/config.yaml
        ''
      )
    ];

    networking.firewall.enable = false;
    services.openssh.enable = true;
    services.getty.autologinUser = "lillecarl";

    nix.optimise.automatic = lib.mkForce false;
    nix.settings.auto-optimise-store = lib.mkForce false;

    virtualisation.containerd.enable = true;

    environment.etc = {
      "kubeadm/config.yaml".text = toYAML [
        initConfig
        clusterConfig
        kubeletConfig
      ];
    };

    systemd.services.kubelet = {
      description = "Kubernetes Kubelet";
      wantedBy = [ "multi-user.target" ];
      after = [
        "network.target"
        "containerd.service"
      ];
      wants = [ "containerd.service" ];

      preStart = ''
        echo "Checking kubeadm initialization state"

        if [[ ! -f /etc/kubernetes/kubelet.conf ]]; then
          echo "ERROR: /etc/kubernetes/kubelet.conf not found"
          echo "Run 'kubeadm init' or 'kubeadm join' first"
          exit 1
        fi

        if [[ ! -f /var/lib/kubelet/config.yaml ]]; then
          echo "ERROR: /var/lib/kubelet/config.yaml not found"
          echo "Run 'kubeadm init' or 'kubeadm join' first"
          exit 1
        fi

        echo "Kubeadm initialization detected, starting kubelet..."
      '';

      serviceConfig = {
        Type = "notify";
        ExecStart = "${pkgs.kubernetes}/bin/kubelet $KUBELET_KUBEADM_ARGS --config=/var/lib/kubelet/config.yaml --kubeconfig=/etc/kubernetes/kubelet.conf";
        EnvironmentFile = "/var/lib/kubelet/kubeadm-flags.env";
        Restart = "always";
        RestartSec = "10s";
        StartLimitInterval = "0";
        KillMode = "process";
        OOMScoreAdjust = "-999";
        CPUAccounting = true;
        MemoryAccounting = true;

        # Security
        NoNewPrivileges = false; # kubelet needs privileges
        ProtectKernelTunables = false;
        ProtectControlGroups = false;
        ProtectSystem = false;
        ProtectHome = false;
      };

      # environment = {
      #   KUBELET_KUBECONFIG_ARGS = "--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf";
      #   KUBELET_CONFIG_ARGS = "--config=/var/lib/kubelet/config.yaml";
      # };
    };

    # Required directories
    systemd.tmpfiles.rules = [
      "d /etc/kubernetes 0755 root root -"
      "d /var/lib/kubelet 0755 root root -"
      "d /var/lib/kubernetes 0755 root root -"
      "d /opt/cni/bin 0755 root root -"
    ];

    microvm = {
      hypervisor = "qemu";

      vcpu = 4;
      mem = 1900;

      writableStoreOverlay = "/nix/.rw-store";
      storeOnDisk = false;
      shares = [
        {
          tag = "ro-store";
          source = "/nix/store";
          mountPoint = "/nix/.ro-store";
        }
      ];
      volumes = [
        {
          image = "nix-store-overlay.img";
          mountPoint = config.microvm.writableStoreOverlay;
          size = 2048;
        }
        {
          image = "var-lib.img";
          mountPoint = "/var/lib";
          size = 2048;
        }
      ];

      interfaces = [
        {
          type = "bridge";
          id = config.networking.hostName;
          bridge = "br0";
          mac = config.lib.micro.mac;
        }
      ];
    };
  };
}
