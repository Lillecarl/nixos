{
  kubenix,
  config,
  lib,
  ...
}:
let
  namespace = "nginx";
in
{
  kubernetes.resources.namespaces.${namespace} = { };
  kubernetes.helm.releases.nginx = {
    namespace = namespace;

    chart = kubenix.lib.helm.fetch {
      repo = "https://kubernetes.github.io/ingress-nginx";
      chart = "ingress-nginx";
      version = "4.12.2";
      sha256 = "sha256-TqN7OJD7GxGCm3mHhPXwaz2Xp0zn1BFzl92jmI68l3c=";
    };

    values = {
      controller.service.ipFamilyPolicy = "RequireDualStack";
      # controller.service.loadBalancerClass = "io.cilium/node";
      # controller.service.externalTrafficPolicy = "Local";
    };
  };
}
