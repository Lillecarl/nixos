{
  config,
  lib,
  helm,
  ...
}:
let
  moduleName = "coredns";
  cfg = config.${moduleName};
in
{
  options.${moduleName} = {
    enable = lib.mkEnableOption moduleName;
    namespace = lib.mkOption {
      type = lib.types.str;
      default = moduleName;
    };
    clusterDomain = lib.mkOption {
      type = lib.types.str;
      default = "cluster.local"; # Kubernetes stupid standard
    };
    clusterIP = lib.mkOption {
      type = lib.types.str;
    };
    helmAttrs = lib.mkOption {
      type = lib.types.anything;
      default = { };
    };
  };
  config = lib.mkIf cfg.enable {
    # Create coredns namespace
    kubernetes.resources.none.Namespace.${cfg.namespace} = { };
    kubernetes.resources.${cfg.namespace}.ConfigMap.coredns = {
      data.Corefile = ''
        .:53 {
            errors
            health {
               lameduck 5s
            }
            ready
            kubernetes ${cfg.clusterDomain} in-addr.arpa ip6.arpa {
               pods insecure
               fallthrough in-addr.arpa ip6.arpa
               ttl 30
            }
            prometheus :9153
            forward . 9.9.9.9 {
               max_concurrent 1000
            }
            cache 30 {
               disable success ${cfg.clusterDomain}
               disable denial ${cfg.clusterDomain}
            }
            loop
            reload
            loadbalance
        }
      '';
    };
    # Create helm release
    helm.releases.${moduleName} = {
      namespace = cfg.namespace;

      chart = helm.fetch {
        repo = "https://coredns.github.io/helm";
        chart = "coredns";
        version = "1.44.3";
        sha256 = "sha256-ITn1hhg1yOGEfZwA/rD5CO1YyWEEa4ZyNenOE2QSopY=";
      };

      values = {
        service.clusterIP = cfg.clusterIP;
        deployment.skipConfig = true;
        tolerations = [
          {
            key = "node-role.kubernetes.io/control-plane";
            operator = "Exists";
            effect = "NoSchedule";
          }
        ];
      }
      // cfg.helmAttrs;
    };
  };
}
