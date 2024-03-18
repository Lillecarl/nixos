{ config
, ...
}: {
  imports = [
    ./atuin.nix
    ./carapace.nix
    ./dircolors.nix
    ./direnv.nix
    ./editorconfig.nix
    ./fd.nix
    ./fish.nix
    ./git.nix
    ./gnome-keyring.nix
    ./gpg.nix
    ./helix.nix
    ./lsd.nix
    ./neovim.nix
    ./nushell.nix
    ./packages.nix
    ./pam.nix
    ./readline.nix
    ./ripgrep.nix
    ./ssh.nix
    ./starship.nix
    ./tealdeer.nix
    ./tmux.nix
    ./xdg-user-dirs.nix
    ./zsh.nix
  ];

  home = {
    file.".local/bin/.keep".text = "";

    inherit (config.pam) sessionVariables;
  };

  xdg.enable = true;

  programs = {
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
        pinentry = "qt";
        sync_interval = 300;
        lock_timeout = 3600 * 24;
      };
    };
  };
}
