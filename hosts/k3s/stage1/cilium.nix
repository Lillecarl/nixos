{
  kubenix,
  config,
  lib,
  ...
}:
let
  namespace = "cilium";
in
{
  # Create cilium namespace
  kubernetes.resources.namespaces.${namespace} = { };
  # Create helm release
  kubernetes.helm.releases.cilium = {
    namespace = namespace;

    chart = kubenix.lib.helm.fetch {
      repo = "https://helm.cilium.io";
      chart = "cilium";
      version = "1.17.5";
      sha256 = "sha256-94xCDaau6blpHx+GmlCmR4QmNfV2b27lMM9hYuDd0do=";
    };

    values = {
      kubeProxyReplacement = true;
      k8sServiceHost = "localhost";
      k8sServicePort = "6443";
      tunnelProtocol = "geneve";
      routingMode = "tunnel";

      # defaultLBServiceIPAM = "lbipam"; # nodeipam | lbipam
      enableLBIPAM = false;
      nodeIPAM.enabled = false;
      # cni.chainingMode="portmap";
      # cni.customConf=true;
      # cni.configMap="cni-configuration";
      ipMasqAgent.enable = true;

      # ipMasqAgent.config.nonMasqueradeCIDRs = "{10.0.0.0/8,172.16.0.0/12,192.168.0.0/16}";
      # ipMasqAgent.config.masqLinkLocal = false;
      # enableMasqueradeRouteSource = false;
      # endpointRoutes.enabled = true;
      policyEnforcementMode = "never";
      # Extra args for cilium-agent
      extraArgs = [
        # "--devices=lo,enp+"
        # "--direct-routing-device=enp1s0"
      ];

      cluster = {
        name = "k3s";
      };
      tls.secretsNamespace.name = namespace;
      ipam.operator = {
        # clusterPoolIPv4PodCIDRList = "10.55.0.0/16";
        # clusterPoolIPv6PodCIDRList = "2001:470:dc1a:1::/104";
      };
      operator.replicas = 1;
      cgroup = {
        autoMount.enabled = true;
        hostRoot = "/sys/fs/cgroup";
      };
      ipv6 = {
        enabled = true;
      };
      bpf = {
        masquerade = false;
      };
      # bgpControlPlane = {
      #   enabled = true;
      #   secretsNamespace.name = "cilium";
      # };
      pmtuDiscovery.enabled = true;
    };
  };
}
