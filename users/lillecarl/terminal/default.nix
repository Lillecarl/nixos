{
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [
    #./default.nix
    ./atuin.nix
    ./awscli.nix
    ./bat.nix
    ./dircolors.nix
    ./direnv.nix
    ./distrobox.nix
    ./editorconfig.nix
    ./fish.nix
    ./git.nix
    ./glab.nix
    ./gnome-keyring.nix
    ./gpg.nix
    ./helix.nix
    ./helix_fat.nix
    ./krew.nix
    ./lsd.nix
    ./nix.nix
    ./noshell.nix
    ./nushell.nix
    ./packages.nix
    ./pam.nix
    ./podman.nix
    ./readline.nix
    ./ripgrep.nix
    ./sessionVariables.nix
    ./ssh.nix
    ./starship.nix
    ./tealdeer.nix
    ./template.nix
    ./tmux.nix
    ./zsh.nix
  ];

  home = {
    file.".local/bin/.keep".text = "";

    inherit (config.pam) sessionVariables;
  };

  xdg.enable = true;

  programs = lib.mkIf (config.ps.terminal.mode == "fat") {
    man = {
      enable = true;
      generateCaches = false;
    };

    zellij = {
      enable = true;

      settings = { };
    };

    rbw = {
      enable = true;
      settings = {
        email = "bitwarden@lillecarl.com";
        pinentry = pkgs.pinentry-qt;
        sync_interval = 300;
        lock_timeout = 3600 * 24;
      };
    };
  };
}
