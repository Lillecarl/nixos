{
  kubenix,
  config,
  lib,
  ...
}:
let
  namespace = "coredns";
in
{
  # Create coredns namespace
  kubernetes.resources.namespaces.${namespace} = { };
  kubernetes.namespace = namespace;
  kubernetes.resources.configMaps.coredns = {
    data.Corefile = ''
      .:53 {
          errors
          health
          ready
          kubernetes k8s.shitbox.lillecarl.com in-addr.arpa ip6.arpa {
            pods insecure
            fallthrough in-addr.arpa ip6.arpa
          }
          prometheus :9153
          forward . 9.9.9.9
          cache 30
          loop
          reload
          loadbalance
      }
    '';
  };
  # Create helm release
  kubernetes.helm.releases.coredns = {
    namespace = namespace;

    chart = kubenix.lib.helm.fetch {
      repo = "https://coredns.github.io/helm";
      chart = "coredns";
      version = "1.42.1";
      sha256 = "sha256-1qLejLYA7LpPZnHxTj6MalkQD68H8zipkBb/S07C69k=";
    };

    values = {
      service.clusterIP = "10.33.0.10";
      deployment.skipConfig = true;
    };
  };
}
