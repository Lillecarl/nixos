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
    ripgrep
    bat
    exa
  ];

  home.stateVersion = "22.05";
}
