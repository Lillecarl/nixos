{ lib, config, ... }:
{
  config = lib.mkIf config.ps.gui.enable {
    services.swaync = {
      enable = true;

      settings = {
        layer = "overlay";
        positionX = "right";
        positiony = "center";
        hide-on-clear = true;
        layer-shell = true;
      };
    };
  };
}
