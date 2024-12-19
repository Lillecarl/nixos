{ lib, config, ... }:
let
  modName = "template";
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
    lib.template = {
      info = "Template module is enabled";
    };
  };
}
