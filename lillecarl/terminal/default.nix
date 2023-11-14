{ config
, pkgs
, inputs
, ...
}: {
  imports = [
    ./direnv.nix
    ./editorconfig.nix
    ./fish.nix
    ./git.nix
    ./gnome-keyring.nix
    ./gpg.nix
    ./neovim
    ./nushell.nix
    ./packages.nix
    ./pam.nix
    ./ssh.nix
    ./starship.nix
    ./tealdeer.nix
    ./tmux.nix
    ./xdg-user-dirs.nix
    ./zsh.nix
  ];

  home.file.".local/bin/.keep".text = "";

  home.sessionVariables = config.pam.sessionVariables;

  xdg.enable = true;

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
