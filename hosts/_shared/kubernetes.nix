{ config
, lib
, inputs
, pkgs
, ...
}:
let
  kubeMasterIP = (builtins.elemAt config.networking.interfaces.br13.ipv4.addresses 0).address
  ;
  kubeMasterHostname = "k8s.${config.networking.hostName}.lillecarl.com";
  kubeMasterAPIServerPort = 6443;
in
{
  imports = [
    inputs.nix-snapshotter.nixosModules.nix-snapshotter
    inputs.nix-snapshotter.nixosModules.preload-containerd
  ];
  config =
    if true then {
      # https://github.com/kubernetes/kubernetes/blob/f44bb5e6e58c315b62c79bbc20814e84eb002e00/cmd/kubeadm/app/preflight/checks_linux.go#L75
      environment.systemPackages = [
        pkgs.cri-tools
        pkgs.ethtool
        pkgs.conntrack-tools
        pkgs.iproute2
        pkgs.iptables
        pkgs.util-linux
        pkgs.socat
        pkgs.coreutils-full

        pkgs.kompose
        pkgs.kubectl
        pkgs.kubernetes
        pkgs.nerdctl
        (pkgs.writeScriptBin "docker" /* bash */ ''
          #! ${pkgs.runtimeShell}
          sudo -E ${pkgs.nerdctl}/bin/nerdctl "$@"
        '')
      ];

      services.certmgr.specs = {
        addonManager.action = lib.mkForce "systemctl try-restart kube-addon-manager.service";
        apiServer.action = lib.mkForce "systemctl try-restart kube-apiserver.service";
        apiserverEtcdClient.action = lib.mkForce "systemctl try-restart kube-apiserver.service";
        apiserverKubeletClient.action = lib.mkForce "systemctl try-restart kube-apiserver.service";
        apiserverProxyClient.action = lib.mkForce "systemctl try-restart kube-apiserver.service";
        controllerManager.action = lib.mkForce "systemctl try-restart kube-controller-manager.service";
        controllerManagerClient.action = lib.mkForce "systemctl try-restart kube-controller-manager.service";
        etcd.action = lib.mkForce "systemctl try-restart etcd.service";
        flannelClient.action = lib.mkForce "systemctl try-restart flannel.service";
        kubeProxyClient.action = lib.mkForce "systemctl try-restart kube-proxy.service";
        kubelet.action = lib.mkForce "systemctl try-restart kubelet.service";
        kubeletClient.action = lib.mkForce "systemctl try-restart kubelet.service";
        schedulerClient.action = lib.mkForce "systemctl try-restart kube-scheduler.service";
        serviceAccount.action = lib.mkForce "systemctl try-restart kube-apiserver.service kube-controller-manager.service";
      };

      systemd.services.certmgr.requires = [ config.systemd.services.cfssl-up.name ];
      systemd.services.kube-addon-manager.requires = [ config.systemd.services.kube-apiserver-up.name ];
      systemd.services.kube-certmgr-bootstrap.requires = [ config.systemd.services.certmgr.name ];
      systemd.services.kube-controller-manager.requires = [ config.systemd.services.kube-apiserver-up.name ];
      systemd.services.kube-proxy.requires = [ config.systemd.services.kube-apiserver-up.name ];
      systemd.services.kube-scheduler.requires = [ config.systemd.services.kube-apiserver-up.name ];

      systemd.services.kube-apiserver.requires = [
        config.systemd.services.etcd.name
        config.systemd.services.kube-certmgr-bootstrap.name
      ];
      systemd.services.kube-apiserver.after = [
        config.systemd.services.etcd.name
        config.systemd.services.kube-certmgr-bootstrap.name
      ];
      systemd.services.kubelet.requires = [
        config.systemd.services.containerd.name
        config.systemd.services.kube-apiserver-up.name
      ];

      systemd.services.cfssl-up = {
        description = "Waits until cfssl is up and running";

        before = [ config.systemd.services.certmgr.name ];
        bindsTo = [ config.systemd.services.cfssl.name ];
        after = [ config.systemd.services.cfssl.name ];
        path = [ pkgs.curl pkgs.jq ];

        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;

          ExecStart = pkgs.writeScript "cfssl-up" /* fish */ ''
            #! ${lib.getExe pkgs.fish} --no-config

            for i in $(seq 1 10)
              echo "Checking if cfssl is up and running... $i"
              # Redirect curl stderr to null, redirect stdout to jq, jq checks if cfssl is healthy
              if curl -k ${config.services.certmgr.specs.apiServer.authority.remote}/api/v1/cfssl/health 2> /dev/null | jq -e '.result.healthy == true' > /dev/null
                echo "cfssl is up and running"
                return 0
              end
              sleep 1
            end

            echo "cfssl is not up and running"
            return 1
          '';
        };
      };

      systemd.services.kube-apiserver-up = {
        description = "Waits until kube-apiserver is up and running";

        before = [ config.systemd.services.kube-addon-manager.name ];
        bindsTo = [ config.systemd.services.kube-apiserver.name ];
        after = [ config.systemd.services.kube-apiserver.name ];
        path = [ pkgs.curl pkgs.ripgrep ];

        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;

          ExecStart = pkgs.writeScript "kube-apiserver-up" /* fish */ ''
            #! ${lib.getExe pkgs.fish} --no-config

            for i in $(seq 1 10)
              echo "Checking if kube-apiserver is up and running... $i"
              if curl -k ${config.services.kubernetes.kubelet.kubeconfig.server}/livez 2> /dev/null | rg --quiet ok
                echo "kube-apiserver is up and running"
                return 0
              end
              sleep 1
            end

            echo "kube-apiserver is not up and running"
            return 1
          '';
        };
      };

      virtualisation.containerd = {
        enable = true;

        settings = {
          plugins."io.containerd.grpc.v1.cri" = {
            containerd.runtimes.runc.options = {
              SystemdCgroup = true;
            };
            registry.mirrors."${config.networking.hostName}.io" = {
              endpoint = [ "https://registry.${config.networking.hostName}.lillecarl.com" ];
            };
            registry.mirrors."local.io" = {
              endpoint = [ "https://registry.${config.networking.hostName}.lillecarl.com" ];
            };
          };
          grpc = {
            address = "/run/containerd/containerd.sock";
            inherit (config.users.groups.kubernetes) gid;
          };
        };
      };

      services.nix-snapshotter = {
        enable = true;
      };
      services.preload-containerd = {
        enable = true;
      };

      environment.extraInit = ''
        export CONTAINERD_NAMESPACE="k8s.io"
      '';

      services.kubernetes = {
        roles = [ "master" "node" ];
        masterAddress = kubeMasterHostname;
        apiserverAddress = "https://${kubeMasterHostname}:${toString kubeMasterAPIServerPort}";
        easyCerts = true;
        apiserver = {
          securePort = kubeMasterAPIServerPort;
          advertiseAddress = kubeMasterIP;
        };
        kubelet = {
          containerRuntimeEndpoint = "unix://${config.virtualisation.containerd.settings.grpc.address}";
          extraOpts = "--fail-swap-on=false --image-service-endpoint unix:///run/nix-snapshotter/nix-snapshotter.sock";
        };
        pki = {
          enable = true;
        };
        apiserver = {
          allowPrivileged = true;
        };

        addons.dns.enable = true;

        addonManager.addons = {
          redis = {
            apiVersion = "v1";
            kind = "Pod";
            metadata = {
              name = "redis";
              namespace = "default";
            };
          };
        };
      };

      # Allow kubernetes group to read cluster-admin
      # Only use on workstations/low-risk machines
      services.certmgr.specs.clusterAdmin.private_key = {
        group = "kubernetes";
        mode = "0640";
      };

      networking.hosts = {
        ${kubeMasterIP} = [ kubeMasterHostname ];
      };
    } else { };
}
