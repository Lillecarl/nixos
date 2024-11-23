{ lib, config, pkgs, ... }:
{
  config = lib.mkIf config.ps.gui.enable {
    programs.chromium = {
      enable = true;
      package = pkgs.chromium;
      dictionaries = [
        pkgs.hunspellDictsChromium.en_US
      ];
    };
  };
}
