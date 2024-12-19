{ lib, config, ... }:
let
  modName = "slim";
  cfg = config.ps.${modName};
in
{
  options.ps = {
    ${modName} = {
      enable = lib.mkOption {
        default = config.ps.terminal.mode == "slim";
        description = "Whether to enable ${modName}.";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    manual = {
      html.enable = false;
      json.enable = false;
      manpages.enable = false;
    };
    programs.man = {
      enable = false;
    };
  };
}
