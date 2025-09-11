{
  lib,
  config,
  pkgs,
  ...
}:
let
  modName = "cloud-init";
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
  config = lib.mkIf cfg.enable {
    services.cloud-init = {
      enable = true;
    };
    environment.systemPackages = [
      pkgs.cloud-init
    ];
  };
}
