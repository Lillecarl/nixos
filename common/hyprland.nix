{ pkgs, inputs, ... }:
let
  finalPackage = pkgs.hyprland-carl;
  finalPortalPackage = pkgs.xdg-desktop-portal-hyprland.override {
    hyprland-share-picker = inputs.hyprland.xdph.packages.x86_64-linux.hyprland-share-picker.override {
      hyprland = finalPackage;
    };
  };
in
{
  environment.systemPackages = [ finalPackage ];
  fonts.enableDefaultPackages = true;

  hardware.opengl.enable = true;

  programs = {
    dconf.enable = true;
    xwayland.enable = true;
  };

  security.polkit.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ finalPortalPackage ];
  };

  programs.nm-applet.enable = true;
}
