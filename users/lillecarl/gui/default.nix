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
  };
}
