{ config, pkgs, lib, inputs, ... }:
let
  pkgs-overlay = import ../pkgs;
in
{
  nixpkgs.overlays = [
    pkgs-overlay
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
