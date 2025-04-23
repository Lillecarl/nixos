{ lib, config, ... }:
let
  modName = "zsh";
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
    programs.starship.enableZshIntegration = true;
    programs.direnv.enableZshIntegration = true;

    programs.zsh = {
      enable = true;

      autocd = true;

      oh-my-zsh = {
        enable = true;

        plugins = [
          "vi-mode"
          "keychain"
          "direnv"
        ];
      };
      initContent = ''
        compinit -d "$XDG_CACHE_HOME"/zsh/zcompdump-"$ZSH_VERSION"
        export HISTFILE="$XDG_STATE_HOME"/zsh/history
      '';
      dotDir = ".config/zsh";
    };
  };
}
