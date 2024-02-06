{ inputs
, pkgs
, self
, ...
}:
{
  imports = [
    "${self}/hm"
  ];
  carl = {
    gui = {
      enable = true;
      hyprland = {
        enable = true;
        monitorConfig = ''
          # Work external display
          monitor=DP-1,3440x1440@60,0x0,1.0
          # Home external display
          monitor=HDMI-A-1,2560x1440@144,0x0,1.0
          # Laptop integrated display
          monitor=eDP-1,1920x1200@60,760x1440,1.0
        '';
        keyboardName = "keymapper";
      };
      foot.enable = false;
      mako.enable = false;
      wezterm.enable = false;
    };
    thinkpad = {
      enable = true;
    };
    bluetooth.enable = true;
  };

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
}
