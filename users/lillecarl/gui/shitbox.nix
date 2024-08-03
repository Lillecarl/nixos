{ inputs
, pkgs
, self
, ...
}:
{
  carl = {
    gui = {
      hyprland = {
        keyboardName = "pykbd";
        monitorConfig = ''
          monitor=HDMI-A-2,2560x1440@120,1080x240,1.0
          monitor=DP-2,1920x1080@143.996002,0x0,1.0
          monitor=DP-2,transform,3
          monitor=DP-1,1920x1080@143.996002,3640x0,1.0
          monitor=DP-1,transform,1
        '';
      };
      foot.enable = false;
      mako.enable = false;
    };
    thinkpad = {
      enable = false;
    };
    bluetooth.enable = true;
  };
}
