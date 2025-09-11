{
  kubenix,
  config,
  lib,
  ...
}:
let
  namespace = "hcloud-ccm";
in
{
  imports = [
    kubenix.modules.submodule
  ];
  options = {

  };
  config = {
    # Create hcloud-ccm namespace
    kubernetes.api.resources.namespaces.${namespace} = { };
    kubernetes.api.resources.secrets.hcloud-token = {
      metadata = {
        inherit namespace;
        name = "hcloud";
      };
      type = "Opaque";
      # data.token = "ref+envsubst://$HCLOUD_TOKEN?asdf=fdsa";
      data.token = "%%HCLOUD_TOKEN%%";
    };
    kubernetes.api.resources.deployments.hcloud-cloud-controller-manager.spec.template.spec.hostNetwork = true;
    # Create helm release
    kubernetes.helm.releases.hcloud-ccm = {
      namespace = namespace;
      overrides = [
        
      ];

      chart = kubenix.lib.helm.fetch {
        repo = "https://charts.hetzner.cloud";
        chart = "hcloud-cloud-controller-manager";
        version = "1.26.0";
        sha256 = "sha256-b4ke7Ok2Qk9P3S9uxoY05ua5R2efDCi78x0ramQOoyw=";
      };

      values = {
        env.HCLOUD_INSTANCES_ADDRESS_FAMILY.value = "dualstack";
        additionalTolerations = [
          {
            key = "node.cilium.io/agent-not-ready";
            operator = "Exists";
          }
        ];
      };
    };
  };
}
