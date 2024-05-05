{ config
, lib
, ...
}:
let
  cfg = config.carl.gui.swaync;
in
{
  options.carl.gui.swaync = with lib; {
    enable = lib.mkOption {
      type = types.bool;
      default = config.carl.gui.enable;
    };
  };
  config = lib.mkIf cfg.enable {
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
