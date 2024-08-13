{ self
, ...
}:
{
  carl = {
    gui = {
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

