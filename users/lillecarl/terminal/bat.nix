{ lib, config, ... }:
{
  programs.bat = lib.mkIf config.ps.terminal.enable {
    enable = true;
    catppuccin.enable = true;
  };
}
