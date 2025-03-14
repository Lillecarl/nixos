{
  lib,
  config,
  pkgs,
  ...
}:
let
  modName = "tmux";
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
    programs.tmux = {
      enable = true;

      sensibleOnTop = true;
      clock24 = true;
      baseIndex = 1;
      escapeTime = 0;

      plugins = with pkgs.tmuxPlugins; [
        vim-tmux-navigator
        catppuccin
      ];

      extraConfig = ''
        source-file ~/.config/tmux/linked.conf
      '';
    };
  };
}
