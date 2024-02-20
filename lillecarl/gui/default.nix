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
      enable = true;
      hyprland = {
        enable = true;
      };
      foot.enable = false;
      mako.enable = false;
      wezterm.enable = false;
    };
  };
}
