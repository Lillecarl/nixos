{ config
, pkgs
, inputs
, ...
}: {
  imports = [
    ./carapace.nix
    ./direnv.nix
    ./editorconfig.nix
    ./fish.nix
    ./git.nix
    ./gnome-keyring.nix
    ./gpg.nix
    ./helix.nix
    ./keymapper.nix
    ./neovim.nix
    ./nushell.nix
    ./packages.nix
    ./pam.nix
    ./readline.nix
    ./ssh.nix
    ./starship.nix
    ./tealdeer.nix
    ./tmux.nix
    ./xdg-user-dirs.nix
    ./zsh.nix
  ];

  home = {
    file.".local/bin/.keep".text = "";

    sessionVariables = config.pam.sessionVariables;
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
      };
    };
  };
}
