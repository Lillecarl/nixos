{ config
, lib
, ...
}:
let
  cfg = config.carl.gui.ags;
in
{
  options.carl.gui.ags = with lib; {
    enable = lib.mkOption {
      type = types.bool;
      default = config.carl.gui.enable;
    };
  };
  config = lib.mkIf cfg.enable {
    programs.ags = {
      enable = true;
    };
  };
}
