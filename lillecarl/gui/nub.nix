{ self
, ...
}:
{
  carl = {
    gui = {
      hyprland = {
        keyboardName = "pykbd";
        monitorConfig = ''
          # Work external display
          monitor=desc:Dell Inc. DELL U3421WE HQDH753,3440x1440@60,0x0,1.0
          # Home external display
          monitor=desc:Huawei Technologies Co. Inc. XWU-CBA 0x00000001,2560x1440@144,0x0,1.0
          # Laptop integrated display
          monitor=desc:AU Optronics 0xFA9B,1920x1200@60,760x1440,1.0
        '';
      };
      foot.enable = false;
      mako.enable = false;
    };
    thinkpad = {
      enable = true;
    };
    bluetooth.enable = true;
  };

  programs.niri.settings = {
    outputs."eDP-1".scale = 1.0;
  };
  programs.niri.config = null;
}

