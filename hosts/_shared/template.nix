{ lib, config, ... }:
let
  modName = "template";
  cfg = config.ps.${modName};
in
{
  options.ps = {
    ${modName} = {
      enable = lib.mkOption {
        default = config.ps.terminal.enable;
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
