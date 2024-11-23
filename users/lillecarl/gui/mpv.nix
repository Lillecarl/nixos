{ lib, config, ... }:
{
  config = lib.mkIf config.ps.gui.enable {
    programs.mpv = {
      enable = true;
      config = { };
    };
  };
}
