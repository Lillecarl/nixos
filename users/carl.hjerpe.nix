{ config
, pkgs
, ...
}:
{
  home.username = "carl.hjerpe";
  home.homeDirectory = "/home/carl.hjerpe/";

  home.packages = with pkgs; [
    xonsh # Python shell
    gitui # git TUI, useful for staging and commiting mostly
    ripgrep # Alternative to grep
    bat # Alternative to cat
    exa # Alternative to ls
    ncdu # ncurses version of "du" 
  ];
}
