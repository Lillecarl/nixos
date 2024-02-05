{ config
, lib
, ...
}:
let
  cfg = config.carl.gui.avizo;
in
{
  options.carl.gui.avizo = with lib; {
    enable = lib.mkOption {
      type = types.bool;
      default = config.carl.gui.enable;
    };
  };
  config = lib.mkIf cfg.enable {
    services.avizo = {
      enable = true;
    };
  };
}
