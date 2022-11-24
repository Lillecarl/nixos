{ config, pkgs, ... }:
let
  pkgs-overlay = import ../pkgs;
  xonsh-overlay = import ../overlays/xonsh-overlay;
in
{
  # HM paths
  home.username = "lillecarl";
  home.homeDirectory = "/home/lillecarl";

  nixpkgs.overlays = [
    pkgs-overlay
    xonsh-overlay
  ];

  home.stateVersion = "22.05";

  home.packages = with pkgs; [
    xonsh
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
