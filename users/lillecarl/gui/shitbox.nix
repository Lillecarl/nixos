{ inputs
, pkgs
, self
, ...
}:
{
  carl = {
    gui = {
      foot.enable = false;
      mako.enable = false;
    };
    thinkpad = {
      enable = false;
    };
    bluetooth.enable = true;
  };
}
