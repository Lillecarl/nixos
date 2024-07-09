{ config
, lib
, pkgs
, ...
}:
let
  kubeMasterIP = "10.13.38.1";
  kubeMasterHostname = "k8s.${config.networking.hostName}.lillecarl.com";
  kubeMasterAPIServerPort = 6443;
in
{
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

      virtualisation.containerd = {
        enable = true;

        settings = {
          plugins."io.containerd.grpc.v1.cri" = {
            enable_unprivileged_ports = true;
            enable_unprivileged_icmp = true;
            registry.mirrors."${config.networking.hostName}.io" = {
              endpoint = [ "https://registry.${config.networking.hostName}.lillecarl.com" ];
            };
            registry.mirrors."local.io" = {
              endpoint = [ "https://registry.${config.networking.hostName}.lillecarl.com" ];
            };
          };
          grpc = {
            address = "/run/containerd/containerd.sock";
            gid = config.users.groups.kubernetes.gid;
          };
        };
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
        };
        pki = {
          enable = true;
        };
        apiserver = {
          extraOpts = "--allow-privileged=true";
        };

        addons.dns.enable = true;

        kubelet.extraOpts = "--fail-swap-on=false";
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
