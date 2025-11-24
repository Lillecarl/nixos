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
    ./btop.nix
    ./dircolors.nix
    ./direnv.nix
    ./distrobox.nix
    ./editorconfig.nix
    ./fish.nix
    ./git.nix
    ./glab.nix
    ./gpg.nix
    ./helix.nix
    ./helix_fat.nix
    ./jj.nix
    ./keepassxc.nix
    ./krew.nix
    ./lsd.nix
    ./neovim.nix
    ./nix.nix
    ./noshell.nix
    ./nushell.nix
    ./packages.nix
    ./pam.nix
    ./podman.nix
    ./pueue.nix
    ./readline.nix
    ./ripgrep.nix
    ./sessionVariables.nix
    ./slim.nix
    ./ssh.nix
    ./starship.nix
    ./tealdeer.nix
    ./television.nix
    ./template.nix
    ./tmux.nix
    ./xonsh.nix
    ./xonsh_mod.nix
    ./zellij.nix
    ./zoxide.nix
    ./zsh.nix
  ];

  home = {
    file.".local/bin/.keep".text = "";

    inherit (config.pam) sessionVariables;
  };

  xdg.enable = true;

  # flatpak xdg openuri portal
  # systemd.user.settings.Manager.DefaultEnvironment = {
  #   PATH = "/run/wrappers/bin:/home/%u/.nix-profile/bin:/nix/profile/bin:/home/%u/.local/state/nix/profile/bin:/etc/profiles/per-user/%u/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin";
  # };

  programs = lib.mkIf (config.ps.terminal.mode == "fat") {
    man = {
      enable = true;
      generateCaches = false;
    };

    rbw = {
      enable = true;
      settings = {
        email = "bitwarden@lillecarl.com";
        #pinentry = pkgs.pinentry-qt;
        sync_interval = 300;
        lock_timeout = 3600 * 24;
      };
    };
  };
}
