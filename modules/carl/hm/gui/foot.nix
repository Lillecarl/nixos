{ config
, lib
, ...
}:
let
  cfg = config.carl.gui.foot;
in
{
  options.carl.gui.foot = with lib; {
    enable = lib.mkOption {
      type = types.bool;
      default = config.carl.gui.enable;
    };
  };
  config = lib.mkIf cfg.enable {
    programs.foot = {
      enable = true;

      server.enable = false;

      settings = {
        main = { };
      };
    };
  };
}
