{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.kubeadm;
  systemdCfg = config.systemd.services;

  # Makes a valid YAML string, supports multiple documents or single attrsets,
  # documents will be JSON formatted since Nix can't render YAML.
  toYAMLStr =
    input:
    if builtins.typeOf input == "list" then
      lib.concatStringsSep "\n---\n" (map (doc: builtins.toJSON doc) input)
    else if builtins.typeOf input == "set" then
      builtins.toJSON input
    else
      throw "toYAML only supports set and list types";

  # Makes a valid YAML string, supports multiple documents or single attrsets,
  # reformatted using "yq-go".
  toYAMLFile =
    filename: input:
    pkgs.runCommand filename
      {
        nativeBuildInputs = [
          pkgs.yq-go
        ];
        yamlContent = toYAMLStr input;
        passAsFile = [ "yamlContent" ];
      }
      #bash
      ''
        yq --prettyPrint < $yamlContentPath > $out
      '';

  kubeletConfigPath = "/var/lib/kubelet/config.yaml";
in
{
  options.services.kubeadm =
    let
      yaml12 = pkgs.formats.yaml_1_2 { };
      yamlType = lib.types.nullOr yaml12.type;
      yamlOption = lib.mkOption {
        type = yamlType;
      };
    in
    {
      enable = lib.options.mkEnableOption "kubeadm";
      package = lib.mkPackageOption pkgs "kubernetes" { };
      recommendedDefaults = lib.options.mkEnableOption "recommended kubeadm settings";
      kubernetesVersion = lib.mkOption {
        description = "Version of Kubernetes to deploy with kubeadm, defaults to pkgs.kubernetes.version";
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
      advertiseAddress = lib.mkOption {
        type = lib.types.str;
        description = "Address to advertise to other nodes";
      };
      masterAddress = lib.mkOption {
        type = lib.types.str;
        description = "Address of an existing APIServer node, automatically configured if we're initializing the cluster.";
      };
      certificateKey = lib.mkOption {
        type = lib.types.str;
        description = "Encryption key for uploading certificates to APIServer";
      };
      port = lib.mkOption {
        type = lib.types.int;
        default = 6443;
        apply = builtins.toString;
      };
      ignorePreflightErrors = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Kubeadm preflight errors to ignore";
      };
      secretsFile = lib.mkOption {
        description = ''
          Path to env file containing variables: KUBEADM_TOKEN, KUBEADM_CERT_KEY
        '';
        type = lib.types.nullOr lib.types.path;
        default = null;
      };
      roles = lib.mkOption {
        type = lib.types.listOf (
          lib.types.enum [
            "init"
            "controlPlane"
            "worker"
          ]
        );
        description = ''
          Kubernetes "roles" to run.
          init = initialize Kubernetes cluster, also adds controlPlane
          controlPlane = run controlplane services (scheduler, apiserver++)
          worker = run cluster workloads (don't add controlPlane taints)

          A node can we all three roles but one one node can be the init node.
        '';

        # Apply function to ensure controlPlane is set for init node
        apply =
          roles:
          lib.pipe roles [
            (x: roles ++ lib.optional (lib.any (role: role == "init") roles) "controlPlane")
            lib.unique
          ];
      };
      cri = lib.mkOption {
        type = lib.types.enum [
          "containerd"
          "cri-o"
        ];
        default = "containerd";
        description = "Container runtime to use";
      };
      criSocket = lib.mkOption {
        type = lib.types.str;
        internal = true;
      };
      criServiceName = lib.mkOption {
        type = lib.types.str;
        internal = true;
      };
      clusterConfiguration = yamlOption;
      initConfiguration = yamlOption;
      joinConfiguration = yamlOption;
      resetConfiguration = yamlOption;
      upgradeConfiguration = yamlOption;
      kubeletConfiguration = yamlOption;
      kubeproxyConfiguration = yamlOption;
    };

  config =
    let
      kubeadm = lib.getExe' cfg.package "kubeadm";
      # Helpers to determine what actions to perform
      isControlPlane = lib.any (role: role == "controlPlane") cfg.roles;
      isInit = lib.any (role: role == "init") cfg.roles;
      isWorker = lib.any (role: role == "worker") cfg.roles;
      isContainerd = cfg.cri == "containerd";
      isCrio = cfg.cri == "cri-o";
      recursiveMkDefault = set: lib.mapAttrsRecursive (name: value: lib.mkDefault value) set;

      initConfigImpure = "/etc/kubeadm/initConfig.yaml";
      joinConfigImpure = "/etc/kubeadm/joinConfig.yaml";

      initConfig = toYAMLFile "initConfig" [
        cfg.clusterConfiguration
        cfg.initConfiguration
        cfg.kubeletConfiguration
        cfg.kubeproxyConfiguration
      ];
      joinConfig = toYAMLFile "joinConfig" [
        cfg.clusterConfiguration
        cfg.joinConfiguration
        cfg.kubeletConfiguration
        cfg.kubeproxyConfiguration
      ];
      upgradeConfig = toYAMLFile "upgradeConfig" [
        cfg.upgradeConfiguration
      ];
      resetConfig = toYAMLFile "resetConfig" [
        cfg.resetConfiguration
      ];
    in
    lib.mkMerge [
      # Set types for the configuration sets
      (lib.mkIf cfg.enable {
        # Configure common settings
        services.kubeadm = recursiveMkDefault {
          # Set Kubernetes version from cfg.package
          kubernetesVersion = cfg.package.version;

          clusterConfiguration = {
            apiVersion = "kubeadm.k8s.io/v1beta4";
            kind = "ClusterConfiguration";
            kubernetesVersion = cfg.kubernetesVersion;
            controlPlaneEndpoint = "${cfg.masterAddress}:${cfg.port}";
            apiServer = {
              certSANs = lib.unique [
                cfg.masterAddress
                cfg.advertiseAddress
              ];
            };
          };

          initConfiguration = {
            apiVersion = "kubeadm.k8s.io/v1beta4";
            kind = "InitConfiguration";
            nodeRegistration.name = config.networking.hostName;
            nodeRegistration.criSocket = cfg.criSocket;
            nodeRegistration.ignorePreflightErrors = cfg.ignorePreflightErrors;
            certificateKey = "\${KUBEADM_CERT_KEY}";
            localAPIEndpoint = {
              advertiseAddress = cfg.advertiseAddress;
              bindPort = 6443;
            };
          };

          joinConfiguration = {
            apiVersion = "kubeadm.k8s.io/v1beta4";
            kind = "JoinConfiguration";
            nodeRegistration.name = config.networking.hostName;
            nodeRegistration.criSocket = cfg.criSocket;
            nodeRegistration.ignorePreflightErrors = cfg.ignorePreflightErrors;
            discovery = {
              bootstrapToken = {
                token = "\${KUBEADM_TOKEN}";
                apiServerEndpoint = "${cfg.masterAddress}:${cfg.port}";
                unsafeSkipCAVerification = true;
              };
            };
          };

          resetConfiguration = {
            apiVersion = "kubeadm.k8s.io/v1beta4";
            kind = "ResetConfiguration";
            criSocket = cfg.criSocket;
          };

          upgradeConfiguration = {
            apiVersion = "kubeadm.k8s.io/v1beta4";
            kind = "UpgradeConfiguration";
            apply.kubernetesVersion = cfg.kubernetesVersion;
            diff.kubernetesVersion = cfg.kubernetesVersion;
            plan.kubernetesVersion = cfg.kubernetesVersion;
          };

          kubeletConfiguration = {
            apiVersion = "kubelet.config.k8s.io/v1beta1";
            kind = "KubeletConfiguration";
          };

          kubeproxyConfiguration = {
            apiVersion = "kubeproxy.config.k8s.io/v1alpha1";
            kind = "KubeProxyConfiguration";
          };
        };
      })
      # Skip marking node as control-plane if it has worker role
      (lib.mkIf cfg.enable (recursiveMkDefault {
        services.kubeadm.initConfiguration.skipPhases = (lib.optional isWorker "mark-control-plane");
      }))
      (lib.mkIf (cfg.enable && isControlPlane) (recursiveMkDefault {
        # Configure node as control-plane (run scheduler and APIserver)
        services.kubeadm.joinConfiguration.controlPlane = {
          certificateKey = "\${KUBEADM_CERT_KEY}";
          localAPIEndpoint = {
            advertiseAddress = cfg.advertiseAddress;
            bindPort = 6443;
          };
        };
      }))
      # Set masterAddress to advertiseAddress if we're initializing a cluster
      (lib.mkIf (cfg.enable && isInit) (recursiveMkDefault {
        services.kubeadm.masterAddress = cfg.advertiseAddress;
      }))
      # Enable and configure containerd specific settings
      (lib.mkIf (cfg.enable && isContainerd) (recursiveMkDefault {
        virtualisation.containerd = {
          enable = true;
          settings = {
            plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options.systemdCgroup = true;
          };
        };
        services.kubeadm.criSocket = "unix:///var/run/containerd/containerd.sock";
        services.kubeadm.criServiceName = config.systemd.services.containerd.name;
      }))
      # Enable and configure containerd specific settings
      (lib.mkIf (cfg.enable && isContainerd) {
        virtualisation.containerd.settings.plugins."io.containerd.grpc.v1.cri".cni.bin_dir =
          lib.mkForce "/opt/cni/bin";
      })
      # Enable and configure cri-o specific settings
      (lib.mkIf (cfg.enable && isCrio) (recursiveMkDefault {
        virtualisation.cri-o.enable = true;
        services.kubeadm.criSocket = "unix:///var/run/crio/crio.sock";
        services.kubeadm.criServiceName = config.systemd.services.crio.name;
      }))
      # If we have configured NixOS swapDevices we shouldn't fail if swap is on
      (lib.mkIf (cfg.enable && config.swapDevices != { }) (recursiveMkDefault {
        services.kubeadm.kubeletConfiguration.failSwapOn = false;
      }))
      # CRI independent configuration
      (lib.mkIf (cfg.enable) {
        # Load kernel modules at boot
        boot.kernelModules = [
          "overlay"
          "br_netfilter"
        ];

        # Sysctl parameters
        boot.kernel.sysctl = {
          "net.bridge.bridge-nf-call-iptables" = 1;
          "net.bridge.bridge-nf-call-ip6tables" = 1;
          "net.ipv4.ip_forward" = 1;
          "net.ipv6.ip_forward" = if config.networking.enableIPv6 then "1" else "0";
        };

        # Install CNI binaries
        system.activationScripts = {
          cni-install = {
            text = ''
              ${lib.getExe pkgs.rsync} --mkpath --recursive ${pkgs.cni-plugins}/bin/ /opt/cni/bin/
            '';
          };
          etcd-chattr = {
            text = ''
              ${lib.getExe' pkgs.coreutils "mkdir"} --parents /var/lib/etcd
              ${lib.getExe' pkgs.e2fsprogs "chattr"} -R +C /var/lib/etcd || ${lib.getExe' pkgs.coreutils "true"}
            '';
          };
        };

        # Dump kubeadm config files in a easy-to-access location
        environment.etc = {
          # Split configuration between files like kubeadm expects them
          # Prevents warnings and makes discovery easier
          # "kubeadm/initConfig.yaml".source = initConfig;
          # "kubeadm/joinConfig.yaml".source = joinConfig;
          "kubeadm/resetConfig.yaml".source = resetConfig;
          "kubeadm/upgradeConfig.yaml".source = upgradeConfig;
          # Configure crictl to target the configured CRI socket
          "crictl.yaml".source =
            lib.pipe
              {
                runtime-endpoint = cfg.criSocket;
                image-endpoint = cfg.criSocket;
              }
              [
                (toYAMLFile "crictl.yaml")
                # cri-o configures this when enabled, override with our settings
                (lib.mkOverride 70)
              ];
        };

        environment.systemPackages =
          let
            kinit = pkgs.writeShellScriptBin "kinit" ''
              sudo -E ${kubeadm} init "$@" --config=${initConfig}
            '';
            kjoin = pkgs.writeShellScriptBin "kjoin" ''
              sudo -E ${kubeadm} join "$@" --config=${joinConfig}
            '';
            kreset = pkgs.writeShellScriptBin "kreset" ''
              sudo -E systemctl stop ${systemdCfg.kubeadm.name} ${systemdCfg.kubelet.name} ${cfg.criServiceName}
              sudo -E ${kubeadm} reset "$@" --config=${resetConfig}
              sudo -E crictl rm --force $(sudo crictl ps -aq) 2>/dev/null || true
              sudo -E crictl rmi --prune 2>/dev/null || true
              sudo -E systemctl start ${systemdCfg.kubeadm.name}
            '';
            kupgrade = pkgs.writeShellScriptBin "kupgrade" ''
              sudo -E ${kubeadm} upgrade "$@" --config=${upgradeConfig}
            '';
          in
          with pkgs;
          [
            kubernetes
            cri-tools
            etcd
            kinit
            kjoin
            kreset
            kupgrade
          ];

        # Required directories
        systemd.tmpfiles.rules = [
          "d /etc/kubernetes 0755 root root -"
          "d /etc/kubernetes/manifests 0755 root root -"
          "d /var/lib/kubelet 0755 root root -"
          "d /var/lib/kubernetes 0755 root root -"
          "d /opt/cni/bin 0755 root root -"
        ];

        systemd.services.kubeadm =
          let
            configScript = # bash
              ''
                # Source secrets
                source ${cfg.secretsFile}
                # Export secrets
                export KUBEADM_TOKEN
                export KUBEADM_CERT_KEY
                # Replace placeholders with secrets
                envsubst < ${initConfig} > ${initConfigImpure}
                envsubst < ${joinConfig} > ${joinConfigImpure}
                # Set permissions
                chmod 700 /etc/kubeadm/initConfig.yaml
                chmod 700 /etc/kubeadm/joinConfig.yaml
              '';
            initScript = # bash
              ''
                ${configScript}
                if [[ ! -f ${kubeletConfigPath} ]]; then
                  echo "Kubeadm not initialized yet. Initializing..."
                  kubeadm init "$@" --config=${initConfigImpure} --upload-certs || exit 1
                  exit 0
                fi
              '';

            joinScript = # bash
              ''
                ${configScript}
                if [[ ! -f ${kubeletConfigPath} ]]; then
                  echo "Kubeadm not initialized yet. Initializing..."
                  kubeadm join "$@" --config=${joinConfigImpure} || exit 1
                  exit 0
                fi
              '';
          in
          {
            description = "kubeadm init";

            wantedBy = [ "multi-user.target" ];
            after = [
              "network.target"
              cfg.criServiceName
            ];
            requires = [ cfg.criServiceName ];

            # Run init script if we have init role, else run join script
            script = if isInit then initScript else joinScript;

            path = with pkgs; [
              kubernetes
              util-linux
              envsubst
            ];

            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = true;
            };
          };

        systemd.services.kubelet = {
          description = "kubelet: The Kubernetes Node Agent";
          wantedBy = [ "multi-user.target" ];
          after = [ "network-online.target" ];
          wants = [ "network-online.target" ];
          requires = [ cfg.criServiceName ];

          unitConfig = {
            ConditionPathExists = "/var/lib/kubelet/config.yaml";
          };

          path = with pkgs; [
            util-linuxMinimal
          ];

          serviceConfig = {
            EnvironmentFile = [
              "-/var/lib/kubelet/kubeadm-flags.env"
              "-/etc/sysconfig/kubelet"
            ];
            ExecStart = "${lib.getExe' pkgs.kubernetes "kubelet"} $KUBELET_KUBECONFIG_ARGS $KUBELET_CONFIG_ARGS $KUBELET_KUBEADM_ARGS $KUBELET_EXTRA_ARGS";
            Restart = "always";
            RestartSec = 1;
            RestartMaxDelaySec = 60;
            RestartSteps = 10;
          };

          environment = {
            KUBELET_KUBECONFIG_ARGS = "--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf";
            KUBELET_CONFIG_ARGS = "--config=/var/lib/kubelet/config.yaml";
          };
        };
      })
    ];
}
