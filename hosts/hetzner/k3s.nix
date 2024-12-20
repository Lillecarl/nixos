{
  lib,
  config,
  pkgs,
  ...
}:
let
  modName = "k3s";
  cfg = config.ps.${modName};
in
{
  options.ps = {
    ${modName} = {
      enable = lib.mkOption {
        default = true;
        description = "Whether to enable ${modName}.";
      };
    };
  };
  config = {
    ps.k3s.enable = !((config.ps.labels.anywhere or "no") == "yes");
    services.k3s = {
      enable = cfg.enable;

      role = config.ps.labels.k8s_role;
    };
    environment.variables = lib.mkIf cfg.enable {
      CONTAINERD_ADDRESS = "/run/k3s/containerd/containerd.sock";
      CONTAINERD_NAMESPACE = "k8s.io";
    };
  };
}
