{ lib, config, ... }:
let
  modName = "readline";
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
    programs.readline = {
      enable = true;

      extraConfig = '''';

      variables = {
        editing-mode = "vi";
        keymap = "vi-command";
        show-mode-in-prompt = "on";
        vi-ins-mode-string = "\\1\\e[6 q\\2";
        vi-cmd-mode-string = "\\1\\e[2 q\\2";
      };
    };
  };
}
