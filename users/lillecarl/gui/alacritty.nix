{ lib, config, ... }:
{
  config = lib.mkIf config.ps.gui.enable {
    programs.alacritty = {
      enable = true;
    };
  };
}
