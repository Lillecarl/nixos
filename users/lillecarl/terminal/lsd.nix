{ lib, config, ... }:
let
  modName = "lsd";
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
    programs.lsd = {
      enable = true;

      settings = {
        icons = {
          theme = if config.ps.terminal.nerdfonts == true then "fancy" else "unicode";
        };
        permission = "octal";
        sorting = {
          dir-grouping = "first";
        };
        ignore-globs = [
          ".git"
        ];
      };
    };
  };
}
