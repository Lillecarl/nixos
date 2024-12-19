{ lib, config, ... }:
let
  modName = "ripgrep";
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
    programs.ripgrep = {
      enable = true;

      arguments = [
        "--hidden"
        "--follow"
        "--smart-case"
        "--max-columns=200"
        "--max-columns-preview"
        "--glob=!.git/*"
      ];
    };
  };
}
