{ inputs
, pkgs
, ...
}:
{
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
  };

  programs.nm-applet.enable = true;
}
