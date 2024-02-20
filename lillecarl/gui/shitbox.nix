{ inputs
, pkgs
, self
, ...
}:
{
  imports = [
    "${self}/modules/hm"
  ];
  carl = {
    gui = {
      hyprland = {
        keyboardName = "keymapper";
        monitorConfig = ''
          monitor=DP-1,2560x1440@164.802002,1080x240,1.0
          monitor=DP-2,1920x1080@143.996002,0x0,1.0
          monitor=DP-2,transform,3
          monitor=DP-3,1920x1080@143.996002,3640x0,1.0
          monitor=DP-3,transform,1
        '';
      };
      foot.enable = false;
      mako.enable = false;
      wezterm.enable = false;
    };
    thinkpad = {
      enable = false;
    };
    bluetooth.enable = false;
  };
}
