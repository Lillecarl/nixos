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
}

