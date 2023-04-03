{ config, pkgs, inputs, ... }:
{
  home.file = {
    # Replace this list once https://github.com/nix-community/home-manager/pull/3235 is ready and merged
    ".config/xonsh/rc.xsh".source = ../dotfiles/.config/xonsh/rc.xsh;
    ".config/xonsh/rc.d/aliases.xsh".source = ../dotfiles/.config/xonsh/rc.d/aliases.xsh;
    ".config/xonsh/rc.d/abbrevs.xsh".source = ../dotfiles/.config/xonsh/rc.d/abbrevs.xsh;
    ".config/xonsh/rc.d/keybindings.xsh".source = ../dotfiles/.config/xonsh/rc.d/keybindings.xsh;
    ".config/xonsh/rc.d/prompt.xsh".source = ../dotfiles/.config/xonsh/rc.d/prompt.xsh;
  };
}
