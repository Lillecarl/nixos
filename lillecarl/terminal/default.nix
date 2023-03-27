{ config, pkgs, inputs, ... }:
{
  imports = [
    ./neovim.nix
    ./nushell.nix
    ./packages.nix
    ./ssh.nix
    ./starship.nix
    ./tealdeer.nix
  ];

  home.file = {
    # Replace this list once https://github.com/nix-community/home-manager/pull/3235 is ready and merged
    ".config/xonsh/rc.xsh".source = ../dotfiles/.config/xonsh/rc.xsh;
    ".config/xonsh/rc.d/aliases.xsh".source = ../dotfiles/.config/xonsh/rc.d/aliases.xsh;
    ".config/xonsh/rc.d/abbrevs.xsh".source = ../dotfiles/.config/xonsh/rc.d/abbrevs.xsh;
    ".config/xonsh/rc.d/keybindings.xsh".source = ../dotfiles/.config/xonsh/rc.d/keybindings.xsh;
    ".config/xonsh/rc.d/prompt.xsh".source = ../dotfiles/.config/xonsh/rc.d/prompt.xsh;
    ".config/xonsh/rc.d/predictors.xsh".source = ../dotfiles/.config/xonsh/rc.d/predictors.xsh;
    ".config/powershell/Microsoft.PowerShell_profile.ps1".source = ../dotfiles/.config/powershell/Microsoft.PowerShell_profile.ps1;
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    enableExtraSocket = true;
  };

  programs.gpg = {
    enable = true;

    mutableKeys = true;
    mutableTrust = true;
  };

  programs.zellij = {
    enable = true;

    settings = { };
  };


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

  programs.git = {
    enable = true;
    userName = "Carl Hjerpe";
    userEmail = "git@hjerpe.xyz";
    lfs.enable = true;

    signing = {
      key = "3916387439FCDA33";
      signByDefault = false;
    };
  };

  programs.rbw = {
    enable = true;
    settings = {
      email = "bitwarden@lillecarl.com";
      pinentry = "qt";
    };
  };

}
