{ inputs
, pkgs
, self
, ...
}:
{
  carl = {
    gui = {
      hyprland = {
        enable = true;
      };
      foot.enable = false;
      mako.enable = false;
    };
  };
}
