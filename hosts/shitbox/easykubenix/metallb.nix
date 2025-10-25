{
  config,
  pkgs,
  lib,
  ...
}:
let
  moduleName = "metal-lb";
  cfg = config.${moduleName};
in
{
  options.${moduleName} = {
    enable = lib.mkEnableOption moduleName;
  };
  config = lib.mkIf cfg.enable {
    kubernetes.resources.metallb-system = {
      IPAddressPool.pool.spec.addresses = [ "192.168.88.20-192.168.88.30" ];
      L2Advertisement.default = { };
    };
    kubernetes.apiMappings = {
      BFDProfile = "metallb.io/v1beta1";
      BGPAdvertisement = "metallb.io/v1beta1";
      BGPPeer = "metallb.io/v1beta2";
      Community = "metallb.io/v1beta1";
      IPAddressPool = "metallb.io/v1beta1";
      L2Advertisement = "metallb.io/v1beta1";
      ServiceBGPStatus = "metallb.io/v1beta1";
      ServiceL2Status = "metallb.io/v1beta1";
    };
    importyaml.metal-lb = {
      src = "https://raw.githubusercontent.com/metallb/metallb/refs/heads/main/config/manifests/metallb-native.yaml";
    };
  };
}
