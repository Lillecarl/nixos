{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    inputs.microvm.nixosModules.microvm
    ../k3s/users.nix
    ../k3s/nix.nix
    ./kubeadm.nix
  ];
  config = {
    system.stateVersion = lib.trivial.release;

    networking.firewall.enable = false;
    services.openssh.enable = true;
    services.getty.autologinUser = "lillecarl";

    nix.optimise.automatic = lib.mkForce false;
    nix.settings.auto-optimise-store = lib.mkForce false;

    services.kubeadm = {
      enable = true;
      roles = [
        "init"
        "worker"
      ];
      environmentFile = pkgs.writeText "kubeadm-secrets" ''
        KUBEADM_TOKEN=abcdef.0123456789abcdef
      '';
      initConfiguration = {
        # bootstrapTokens = [
        #   {
        #     groups = [
        #       "system:bootstrappers:kubeadm:default-node-token"
        #     ];
        #     token = "abcdef.0123456789abcdef";
        #     ttl = "24h0m0s";
        #     usages = [
        #       "signing"
        #       "authentication"
        #     ];
        #   }
        # ];
        skipPhases = [
          "addon/kube-proxy"
          "addon/coredns"
        ];
        localAPIEndpoint = {
          advertiseAddress = config.lib.micro.ip4;
          bindPort = 6443;
        };
        nodeRegistration = {
          ignorePreflightErrors = [
            "Mem"
            "Swap"
          ];
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
      clusterConfiguration = {
        caCertificateValidityPeriod = "87600h0m0s";
        certificateValidityPeriod = "8760h0m0s";
        clusterName = "kubeadm-lab";
        controllerManager = { };
        dns = {
          disabled = true;
        };
        proxy = {
          disabled = true;
        };
        scheduler = { };
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
        networking = {
          dnsDomain = "klab.lillecarl.com";
          serviceSubnet = "10.96.0.0/16";
          podSubnet = "10.97.0.0/16";
        };
      };
    };

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
