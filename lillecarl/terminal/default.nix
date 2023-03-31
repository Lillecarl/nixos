{ config, pkgs, inputs, ... }:
{
  imports = [
    ./git.nix
    ./gpg.nix
    ./neovim.nix
    ./nushell.nix
    ./packages.nix
    ./pam.nix
    ./ssh.nix
    ./starship.nix
    ./tealdeer.nix
    ./xonsh.nix
    ./zsh.nix
  ];

  home.file = {
    ".config/powershell/Microsoft.PowerShell_profile.ps1".source = ../dotfiles/.config/powershell/Microsoft.PowerShell_profile.ps1;
  };

  home.sessionVariables = config.pam.sessionVariables;

  programs.zellij = {
    enable = true;

    settings = { };
  };

  programs.rbw = {
    enable = true;
    settings = {
      email = "bitwarden@lillecarl.com";
      pinentry = "qt";
    };
  };
}
