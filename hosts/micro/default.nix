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
    boot.kernelPackages = pkgs.linuxPackages_latest;

    networking.firewall.enable = false;
    services.openssh.enable = true;
    services.getty.autologinUser = "lillecarl";

    nix.optimise.automatic = lib.mkForce false;
    nix.settings.auto-optimise-store = lib.mkForce false;

    services.kubeadm = {
      enable = true;
      secretsFile = pkgs.writeText "kubeadm-secrets" ''
        KUBEADM_TOKEN=abcdef.0123456789abcdef
        KUBEADM_CERT_KEY=61ce66f6db90277e9a5fc42fabf223ce59dbc40dc91583d03a25bba4f328865f
      '';
      ignorePreflightErrors = [
        "Mem"
        "Swap"
      ];
      initConfiguration = {
        bootstrapTokens = [
          {
            groups = [
              "system:bootstrappers:kubeadm:default-node-token"
            ];
            token = "\${KUBEADM_TOKEN}";
            ttl = "24h0m0s";
            usages = [
              "signing"
              "authentication"
            ];
          }
        ];
        # We deploy these ourselves
        skipPhases = [
          "addon/kube-proxy"
          "addon/coredns"
        ];
        nodeRegistration = { };
      };
      clusterConfiguration = {
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
            #   # Make etcd RAM friendly
            extraArgs = lib.mapAttrsToList (name: value: { inherit name value; }) {
              quota-backend-bytes = "${toString (32 * 1024 * 1024)}";
              max-request-bytes = "${toString (2 * 1024 * 1024)}";
              auto-compaction-retention = "1";
              snapshot-count = "1000";
              max-txn-ops = "128";
              heartbeat-interval = "1000";
              election-timeout = "10000";
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
      mem = 1024;
      balloon = true;

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
