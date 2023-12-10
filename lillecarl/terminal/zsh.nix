_:
{
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
    initExtra = ''
      compinit -d "$XDG_CACHE_HOME"/zsh/zcompdump-"$ZSH_VERSION"
      export HISTFILE="$XDG_STATE_HOME"/zsh/history
    '';
    dotDir = ".config/zsh";
  };
}
