{ inputs
, pkgs
, self
, ...
}:
{
  carl = {
    gui = {
      enable = true;
      hyprland = {
        enable = true;
      };
      foot.enable = false;
      mako.enable = false;
    };
  };
}
