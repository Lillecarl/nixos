{ config
, lib
, ...
}:
let
  cfg = config.carl.gui.alacritty;
in
{
  options.carl.gui.alacritty = with lib; {
    enable = lib.mkOption {
      type = types.bool;
      default = config.carl.gui.enable;
    };
  };
  config = lib.mkIf cfg.enable {
    programs.alacritty = {
      enable = true;
    };
  };
}
