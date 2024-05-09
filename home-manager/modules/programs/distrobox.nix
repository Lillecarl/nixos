{ config, pkgs, lib, ... }:
let
  cfg = config.programs.distrobox;
in
{
  options.prorams.distrobox = {
    enable = lib.mkEnableOption "Enable distrobox";
  };
}
