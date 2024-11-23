{ lib, config, ... }:
{
  programs.awscli = lib.mkIf config.ps.terminal.enable {
    enable = true;
  };
}
