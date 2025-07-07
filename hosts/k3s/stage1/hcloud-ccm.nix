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
  options = {

  };
  config = {
    # Create hcloud-ccm namespace
    kubernetes.resources.namespaces.${namespace} = { };
    # Create helm release
    kubernetes.helm.releases.hcloud-ccm = {
      namespace = namespace;

      chart = kubenix.lib.helm.fetch {
        repo = "https://charts.hetzner.cloud";
        chart = "hcloud-cloud-controller-manager";
        version = "1.26.0";
        sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
      };

      values = {

      };
    };
  };
}
