{ lib, config, ... }:
let
  modName = "awscli";
  cfg = config.ps.${modName};
in
{
  options.ps = {
    ${modName} = {
      enable = lib.mkOption {
        default = config.ps.terminal.mode == "fat";
        description = "Whether to enable ${modName}.";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    programs.awscli = {
      enable = cfg.enable;
    };
  };
}
