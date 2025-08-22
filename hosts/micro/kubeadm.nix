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
  kubeConfigPath = "/etc/kubernetes/kubelet.conf";
  kubeadmInitPath = "/var/lib/kubelet/init";
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
      kubernetesVersion = lib.mkOption {
        description = "Version of Kubernetes to deploy with kubeadm";
        type = lib.types.str;
        default = pkgs.kubernetes.version;
      };
      recommendedDefaults = lib.options.mkEnableOption "recommended kubeadm settings";
      environmentFile = lib.mkOption {
        description = ''
          Path to env file containing KUBEADM_TOKEN
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
          Kubernetes "roles" to run. Only one machine should have "init".
        '';
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
      criSocketPath = lib.replaceStrings [ "unix://" ] [ "" ] cfg.criSocket;

      initConfig = toYAMLFile "initConfig" [
        cfg.clusterConfiguration
        cfg.initConfiguration
        cfg.kubeletConfiguration
        cfg.kubeproxyConfiguration
      ];
      joinConfig = toYAMLFile "joinConfig" [
        cfg.joinConfiguration
        cfg.kubeletConfiguration
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
        services.kubeadm = lib.mapAttrsRecursive (name: value: lib.mkDefault value) {
          clusterConfiguration.apiVersion = "kubeadm.k8s.io/v1beta4";
          clusterConfiguration.kind = "ClusterConfiguration";
          clusterConfiguration.kubernetesVersion = cfg.kubernetesVersion;

          initConfiguration.apiVersion = "kubeadm.k8s.io/v1beta4";
          initConfiguration.kind = "InitConfiguration";
          initConfiguration.nodeRegistration.name = config.networking.hostName;
          initConfiguration.nodeRegistration.criSocket = cfg.criSocket;

          joinConfiguration.apiVersion = "kubeadm.k8s.io/v1beta4";
          joinConfiguration.kind = "JoinConfiguration";

          resetConfiguration.apiVersion = "kubeadm.k8s.io/v1beta4";
          resetConfiguration.kind = "ResetConfiguration";
          resetConfiguration.criSocket = cfg.criSocket;

          upgradeConfiguration.apiVersion = "kubeadm.k8s.io/v1beta4";
          upgradeConfiguration.kind = "UpgradeConfiguration";
          upgradeConfiguration.apply.kubernetesVersion = cfg.kubernetesVersion;
          upgradeConfiguration.diff.kubernetesVersion = cfg.kubernetesVersion;
          upgradeConfiguration.plan.kubernetesVersion = cfg.kubernetesVersion;

          kubeletConfiguration.apiVersion = "kubelet.config.k8s.io/v1beta1";
          kubeletConfiguration.kind = "KubeletConfiguration";

          kubeproxyConfiguration.apiVersion = "kubeproxy.config.k8s.io/v1alpha1";
          kubeproxyConfiguration.kind = "KubeProxyConfiguration";
        };
      })
      # Skip marking node as control-plane if it has worker role
      (lib.mkIf cfg.enable {
        services.kubeadm.initConfiguration.skipPhases = (
          lib.optional (lib.any (role: role == "worker") cfg.roles) "mark-control-plane"
        );
      })
      # Enable and configure containerd specific settings
      (lib.mkIf (cfg.enable && cfg.cri == "containerd") {
        virtualisation.containerd.enable = true;
        services.kubeadm.criSocket = lib.mkDefault "unix:///var/run/containerd/containerd.sock";
        services.kubeadm.criServiceName = lib.mkDefault config.systemd.services.containerd.name;
      })
      # Enable and configure cri-o specific settings
      (lib.mkIf (cfg.enable && cfg.cri == "cri-o") {
        virtualisation.cri-o.enable = true;
        services.kubeadm.criSocket = lib.mkDefault "unix:///var/run/crio/crio.sock";
        services.kubeadm.criServiceName = lib.mkDefault config.systemd.services.crio.name;
      })
      # CRI independent configuration
      (lib.mkIf (cfg.enable) {
        # Kubernetes requires IP forwarding, kubeadm preflight fails without
        boot.kernel.sysctl."net.ipv4.ip_forward" = "1";
        boot.kernel.sysctl."net.ipv6.ip_forward" = if config.networking.enableIPv6 then "1" else "0";

        # Dump kubeadm config files in a easy-to-access location
        environment.etc = {
          # Split configuration between files like kubeadm expects them
          # Prevents warnings and makes discovery easier
          "kubeadm/initConfig.yaml".source = initConfig;
          "kubeadm/joinConfig.yaml".source = joinConfig;
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

        # Configure KUBECONFIG to use what kubeadm gives us by default.
        # Requires superuser permissions when invoking kubectl
        environment.sessionVariables = {
          KUBECONFIG = "/etc/kubernetes/admin.conf";
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
              # sudo -E systemctl start ${systemdCfg.kubeadm.name}
            '';
            kupgrade = pkgs.writeShellScriptBin "kupgrade" ''
              sudo -E ${kubeadm} upgrade "$@" --config=${upgradeConfig}
            '';
          in
          with pkgs;
          [
            htop
            kubernetes
            cri-tools
            kinit
            kjoin
            kreset
            kupgrade
          ];

        # Required directories
        systemd.tmpfiles.rules = [
          "d /etc/kubernetes 0755 root root -"
          "d /var/lib/kubelet 0755 root root -"
          "d /var/lib/kubernetes 0755 root root -"
          "d /opt/cni/bin 0755 root root -"
        ];

        systemd.services.kubeadm =
          let
            initScript = # bash
              ''
                source ${cfg.environmentFile} || true

                if [[ ! -f ${kubeletConfigPath} ]]; then
                  echo "Kubeadm not initialized yet. Initializing..."
                  kubeadm init "$@" --config=${initConfig} || exit 1
                  exit 0
                fi
              '';

            joinScript = # bash
              ''
                source ${cfg.environmentFile} || true

                if [[ ! -f ${kubeletConfigPath} ]]; then
                  echo "Kubeadm not initialized yet. Initializing..."
                  kubeadm join "$@" --config=${joinConfig} --token $KUBEADM_TOKEN || exit 1
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

            script = initScript;

            path = with pkgs; [
              kubernetes
              util-linux
            ];

            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = true;
            };
          };

        systemd.services.kubelet = {
          enable = true;
          description = "kubeadm kubelet";
          wantedBy = [ config.systemd.services.kubeadm.name ];

          path = with pkgs; [
            kubernetes
            util-linux
          ];

          preStart = ''
            echo "Checking kubeadm initialization state"

            if [[ ! -f ${kubeConfigPath} ]]; then
              echo "ERROR: ${kubeConfigPath} not found"
              echo "Run 'kubeadm init' or 'kubeadm join' first"
              exit 1
            fi

            if [[ ! -f ${kubeletConfigPath} ]]; then
              echo "ERROR: ${kubeletConfigPath} not found"
              echo "Run 'kubeadm init' or 'kubeadm join' first"
              exit 1
            fi

            echo "Kubeadm initialization detected, starting kubelet..."
          '';

          script = ''
            source /var/lib/kubelet/kubeadm-flags.env || true
            source ${cfg.environmentFile} || true
            exec kubelet \
              $KUBELET_KUBEADM_ARGS \
              --config=${kubeletConfigPath} \
              --kubeconfig=${kubeConfigPath}
          '';

          unitConfig = {
            ConditionPathExists = kubeletConfigPath;
          };

          serviceConfig = {
            Type = "notify";
            Restart = "always";
            RestartSec = "10s";
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
        };
      })
    ];
}
