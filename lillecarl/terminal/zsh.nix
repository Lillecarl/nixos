# zsh is my login shell because xonsh is too weird to be login shell.
# This is only a bare-minimum configuration.
{ config
, pkgs
, inputs
, ...
}: {
  programs.zsh = {
    enable = true;

    autocd = true;

    oh-my-zsh = {
      enable = true;

      plugins = [
        "vi-mode"
        "keychain"
      ];
    };
  };
}
