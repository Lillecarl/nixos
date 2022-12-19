{ config
, pkgs
, ...
}:
{
  programs.home-manager.enable = true;

  home.username = "root";
  home.homeDirectory = "/root/";

  home.packages = with pkgs; [
    salt # Salt client and server
    xonsh # Python shell
    gitui # git TUI, useful for staging and commiting mostly
    ripgrep # Alternative to grep
    bat # Alternative to cat
    exa # Alternative to ls
    ncdu # ncurses version of "du" 
    zabbix.agent2 # Zabbix agent
  ];

  home.stateVersion = "22.05";
}
