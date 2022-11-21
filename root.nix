{ config
, pkgs
, ...
}:
{
  programs.home-manager.enable = true;

  home.username = "root";
  home.homeDirectory = "/root/";

  home.packages = with pkgs; [
    salt
    xonsh
    gitui
  ];

  home.stateVersion = "22.05";
}
