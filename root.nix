{ config
, pkgs
, ...
}:
let
  pkgs-overlay = import ./pkgs;
in
{
  nixpkgs.overlays = [
    pkgs-overlay
  ];

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
    #vp_zabbix-agent2 # Zabbix agent, "Viaplay Edition" (Same version as zabbix-server). Unitl we have a build-server with binary cache this isn't feasible.
  ];

  home.stateVersion = "22.05";
}
