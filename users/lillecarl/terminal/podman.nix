{
  lib,
  config,
  pkgs,
  ...
}:
let
  modName = "podman";
  cfg = config.ps.${modName};
in
{
  options.ps = {
    ${modName} = {
      enable = lib.mkOption {
        default = false;
        description = "Whether to enable ${modName}.";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    services.podman = {
      enable = true;
    };
    home.packages = [
      pkgs.kind
    ];
  };
}
