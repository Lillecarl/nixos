{ lib, config, pkgs, ... }:
{
  config = lib.mkIf config.ps.gui.enable {
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
