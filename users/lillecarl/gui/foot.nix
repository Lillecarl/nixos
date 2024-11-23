{ lib, config, ... }:
{
  config = lib.mkIf config.ps.gui.enable {
    programs.foot = {
      enable = true;

      server.enable = false;

      settings = {
        main = { };
      };
    };
  };
}
