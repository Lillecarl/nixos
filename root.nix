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
    zabbix.agent2
  ];

  home.stateVersion = "22.05";
}
