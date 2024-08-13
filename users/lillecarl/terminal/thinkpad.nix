{ config
, lib
, pkgs
, nixosConfig
, ...
}:
let
  cfg = config.carl.thinkpad;
in
{
  options.carl.thinkpad = with lib; {
    enable = mkEnableOption "Enable ThinkPad support";
  };
  config = lib.mkIf cfg.enable { };
}
