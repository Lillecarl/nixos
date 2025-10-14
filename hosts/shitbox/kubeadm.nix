{
  config,
  pkgs,
  lib,
  ...
}:
{
  config.services.kubeadm = {
    enable = false;
    roles = [ "init" ];
    advertiseAddress = "192.168.88.2";
    secretsFile = pkgs.writeText "kubeadm-secrets" ''
      KUBEADM_TOKEN=abcdef.0123456789abcdef
      KUBEADM_CERT_KEY=61ce66f6db90277e9a5fc42fabf223ce59dbc40dc91583d03a25bba4f328865f
    '';
    ignorePreflightErrors = [
      "Mem"
      "Swap"
    ];
    initConfiguration = {
      bootstrapTokens = [
        {
          groups = [
            "system:bootstrappers:kubeadm:default-node-token"
          ];
          token = "\${KUBEADM_TOKEN}";
          ttl = "24h0m0s";
          usages = [
            "signing"
            "authentication"
          ];
        }
      ];
      # We deploy these ourselves
      skipPhases = [
        "addon/kube-proxy"
        "addon/coredns"
      ];
      nodeRegistration = { };
    };
    clusterConfiguration = {
      clusterName = "kubeadm-lab";
      controllerManager = { };
      dns = {
        disabled = true;
      };
      proxy = {
        disabled = true;
      };
      scheduler = { };
      etcd = {
        local = {
          #   # Make etcd RAM friendly
          extraArgs = lib.mapAttrsToList (name: value: { inherit name value; }) {
            quota-backend-bytes = "${toString (32 * 1024 * 1024)}";
            max-request-bytes = "${toString (2 * 1024 * 1024)}";
            auto-compaction-retention = "1";
            snapshot-count = "1000";
            max-txn-ops = "128";
            heartbeat-interval = "1000";
            election-timeout = "10000";
          };
        };
      };
      networking = {
        dnsDomain = "ksb.lillecarl.com";
        serviceSubnet = "10.133.0.0/16";
        podSubnet = "10.134.0.0/16";
      };
    };
  };
}
