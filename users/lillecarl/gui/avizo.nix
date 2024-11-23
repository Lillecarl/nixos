{ lib, config, ... }:
{
  config = lib.mkIf config.ps.gui.enable {
    services.avizo = {
      enable = true;
    };
  };
}
