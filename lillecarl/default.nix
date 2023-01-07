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
    ./terminal.nix # Things that run without a GUI
    ./gui.nix # Things that run with a GUI
    ./kde.nix # KDE configuration
  ];

  # HM stuff
  home.username = "lillecarl";
  home.homeDirectory = "/home/lillecarl";
  home.stateVersion = "22.05";
  home.enableNixpkgsReleaseCheck = true;
  programs.home-manager.enable = true;
}
