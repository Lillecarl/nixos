{ lib, config, pkgs, ... }:
{
  programs.starship = lib.mkIf config.ps.terminal.enable {
    enable = true;
    enableNushellIntegration = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableIonIntegration = true;
  };
}
