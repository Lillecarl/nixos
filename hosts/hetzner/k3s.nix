{ lib, config, ... }:
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
    ps.k3s.enable = !config.ps.smth.anywhere or true;
    services.k3s = {
      enable = cfg.enable;

      role = config.ps.labels.k8s_role;
    };
  };
}
