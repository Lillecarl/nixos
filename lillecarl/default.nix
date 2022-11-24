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

  home.file = {
    ".config/xonsh/rc.xsh".source = ./dotfiles/.config/xonsh/rc.xsh;
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
