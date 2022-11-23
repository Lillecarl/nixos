{ config, pkgs, ... }:
{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "lillecarl";
  home.homeDirectory = "/home/lillecarl";

  home.stateVersion = "22.05";

  home.packages = with pkgs; [

  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
