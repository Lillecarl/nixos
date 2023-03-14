{ config, pkgs, lib, inputs, ... }:
let
  pkgs-overlay = import ../pkgs;
  xonsh-overlay = import ../overlays/xonsh-overlay;
in
{
  nixpkgs.overlays = [
    pkgs-overlay
    xonsh-overlay
  ];

  nixpkgs = {
    config.allowUnfree = true;
  };

  xdg = {
    enable = true;
  };

  # HM stuff
  home.username = "lillecarl";
  home.homeDirectory = "/home/lillecarl";
  home.stateVersion = "22.05";
  home.enableNixpkgsReleaseCheck = true;
  programs.home-manager.enable = true;
}
