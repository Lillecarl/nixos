{ lib, config, pkgs, ... }:
{
  config = lib.mkIf config.ps.gui.enable {
    home.packages = [
      pkgs.vieb
    ];
  };
}
