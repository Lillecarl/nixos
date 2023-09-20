{ pkgs, ... }:
{
  # Taken from https://github.com/hyprwm/Hyprland/blob/main/nix/module.nix
  # TODO: xdg.portal should be implemented as a HM module.
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };
  programs.dconf.enable = true;
  security.polkit.enable = true;

  # nm-applet is a NixOS module for some reason. TODO: Make HM module
  programs.nm-applet.enable = true;
}
