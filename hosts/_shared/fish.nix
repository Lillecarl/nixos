{ lib, config, ... }:
let
  modName = "fish";
  cfg = config.ps.${modName};
in
{
  options.ps = {
    ${modName} = {
      enable = lib.mkOption {
        default = config.ps.workstation.enable;
        description = "Whether to enable ${modName}.";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    programs.fish = {
      enable = true;

      useBabelfish = true;

      vendor = {
        completions.enable = true;
        config.enable = true;
        functions.enable = true;
      };
    };
  };
}
