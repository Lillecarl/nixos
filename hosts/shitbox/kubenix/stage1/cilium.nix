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
      version = "1.17.4";
      sha256 = "sha256-NsOOFJN3hEytx9GuPoJ6SQo/lxjVogkuZtgsvbLUMoE=";
    };

    values = {
      kubeProxyReplacement = true;
      k8sServiceHost = "localhost";
      k8sServicePort = "6443";
      tunnelProtocol = "geneve";
      routingMode = "tunnel";

      ipMasqAgent.config.nonMasqueradeCIDRs = "{10.0.0.0/8,172.16.0.0/12,192.168.0.0/16}";
      ipMasqAgent.config.masqLinkLocal = false;
      enableMasqueradeRouteSource = false;
      endpointRoutes.enabled = true;
      policyEnforcementMode = "never";

      cluster = {
        name = "default";
      };
      tls.secretsNamespace.name = namespace;
      nodeIPAM.enabled = true;
      ipam.operator = {
        clusterPoolIPv4PodCIDRList = "10.55.0.0/16";
        # clusterPoolIPv6PodCIDRList = "2a01:4f9:c01f:e028::/64"
      };
      operator.replicas = 1;
      cgroup = {
        autoMount.enabled = false;
        hostRoot = "/sys/fs/cgroup";
      };
      # ipv6         = { enabled = true; };
      bpf = {
        masquerade = true;
      };
    };
  };
}
