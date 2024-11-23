{ lib, config, ... }:
{
  programs.direnv = lib.mkIf config.ps.terminal.enable {
    enable = true;

    enableBashIntegration = true;
    enableNushellIntegration = true;
    enableZshIntegration = true;
  };
}
