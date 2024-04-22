{ config
, lib
, ...
}:
let
  cfg = config.carl.gui.mpv;
in
{
  options.carl.gui.mpv = with lib; {
    enable = lib.mkOption {
      type = types.bool;
      default = config.carl.gui.enable;
    };
  };
  config = lib.mkIf cfg.enable {
    programs.mpv = {
      enable = true;
      config = { };
    };
  };
}
