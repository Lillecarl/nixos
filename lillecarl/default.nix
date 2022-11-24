{ config, pkgs, ... }:
let
  pkgs-overlay = import ../pkgs;
  xonsh-overlay = import ../overlays/xonsh-overlay;
in
{

  nixpkgs.overlays = [
    pkgs-overlay
    xonsh-overlay
  ];

  imports = [
  ];

  home.file = { # Replace this list once https://github.com/nix-community/home-manager/pull/3235 is ready and merged
    ".config/xonsh/rc.xsh".source = ./dotfiles/.config/xonsh/rc.xsh;
    ".config/xonsh/rc.d/aliases.xsh".source = ./dotfiles/.config/xonsh/rc.d/aliases.xsh;
    ".config/xonsh/rc.d/keybindings.xsh".source = ./dotfiles/.config/xonsh/rc.d/keybindings.xsh;
    ".config/xonsh/rc.d/prompt.xsh".source = ./dotfiles/.config/xonsh/rc.d/prompt.xsh;
    ".config/starship.toml".source = ./dotfiles/.config/starship.toml;
  };


  home.packages = with pkgs; [
    xonsh # xonsh shell

    # Chat apps
    element-desktop # Element Slack app
    teams # Microsoft Teams collaboration suite (Electron)
    slack # Team collaboration chat (Electron)
    discord # Gaming chat application
    zoom # Meetings application
    signal-desktop # Secure messenger

    # Media apps
    mpv # Media Player
    celluloid #  MPV GTK frontend wrapper
    #vlc # VLC sucks in comparision to MPV

  ];

  # HM stuff
  home.username = "lillecarl";
  home.homeDirectory = "/home/lillecarl";
  home.stateVersion = "22.05";
  programs.home-manager.enable = true;
}
