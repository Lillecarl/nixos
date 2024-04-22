{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.carl.gui.chromium;
in
{
  options.carl.gui.chromium = with lib; {
    enable = lib.mkOption {
      type = types.bool;
      default = config.carl.gui.enable;
    };
  };
  config = lib.mkIf cfg.enable {
    programs.chromium = {
      enable = true;
      package = pkgs.chromium;
      dictionaries = [
        pkgs.hunspellDictsChromium.en_US
      ];
    };
  };
}
