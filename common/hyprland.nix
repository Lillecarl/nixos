{ inputs
, pkgs
, ...
}:
{
  programs.hyprland = {
    enable = true;
    package = pkgs.hyprland;
  };

  programs.nm-applet.enable = true;
}
