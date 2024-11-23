{ lib, config, ... }:
{
  programs.dircolors = lib.mkIf config.ps.terminal.enable {
    enable = true;
  };
}
