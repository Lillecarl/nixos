{ lib, config, pkgs, ... }:
{
  programs.helix = lib.mkIf config.ps.editors.enable {
    enable = config.ps.editors.enable;

    settings = { };
  };
}
