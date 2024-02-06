{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.carl.gui.obs;
in
{
  options.carl.gui.obs = with lib; {
    enable = lib.mkOption {
      type = types.bool;
      default = config.carl.gui.enable;
    };
  };
  config = lib.mkIf cfg.enable {
    programs.obs-studio = {
      enable = true;

      plugins = with pkgs.obs-studio-plugins; [
        input-overlay
        looking-glass-obs
        obs-gstreamer
        obs-vaapi
        obs-vkcapture
        wlrobs
      ];
    };
  };
}
