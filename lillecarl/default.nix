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
    ./terminal.nix
    ./gui.nix
  ];



  # HM stuff
  home.username = "lillecarl";
  home.homeDirectory = "/home/lillecarl";
  home.stateVersion = "22.05";
  programs.home-manager.enable = true;
}
