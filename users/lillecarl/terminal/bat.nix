{ lib, config, ... }:
let
  modName = "bat";
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
    programs.bat = {
      enable = true;
      catppuccin.enable = true;
    };
  };
}
