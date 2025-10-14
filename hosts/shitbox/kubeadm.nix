{
  config,
  pkgs,
  lib,
  ...
}:
{
  config = {
    # Configure the most basic (ISH) CNI there is)
    environment.etc."cni/net.d/10-bridge.conflist" = {
      text = builtins.toJSON {
        cniVersion = "1.0.0";
        name = "bridge";
        plugins = [
          {
            type = "bridge";
            bridge = "cni0";
            isGateway = true;
            ipMasq = true;
            ipam = {
              type = "host-local";
              subnet = config.services.kubeadm.clusterConfiguration.networking.podSubnet;
              routes = [ { dst = "0.0.0.0/0"; } ];
            };
          }
          {
            type = "portmap";
            capabilities.portMappings = true;
          }
        ];
      };
    };
    services.kubeadm = {
      enable = true;
      roles = [ "init" ];
      advertiseAddress = "10.13.39.1";
      secretsFile = pkgs.writeText "kubeadm-secrets" ''
        # KUBEADM_TOKEN=abcdef.0123456789abcdef
        # KUBEADM_CERT_KEY=61ce66f6db90277e9a5fc42fabf223ce59dbc40dc91583d03a25bba4f328865f
      '';
      ignorePreflightErrors = [
        "Mem"
        "Swap"
      ];
      initConfiguration = {
        # We deploy these ourselves
        skipPhases = [
          "addon/kube-proxy"
          "addon/coredns"
        ];
        nodeRegistration = { };
      };
      clusterConfiguration = {
        clusterName = "shitbox";
        controllerManager = { };
        dns = {
          disabled = true;
        };
        proxy = {
          disabled = true;
        };
        scheduler = { };
        etcd = { };
        networking = {
          dnsDomain = "ksb.lillecarl.com";
          serviceSubnet = "10.133.0.0/16";
          podSubnet = "10.134.0.0/16";
        };
      };
    };
  };
}
