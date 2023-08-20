{ pkgs
, lib
, ...
}:
{
  xdg = {
    portal = {
      wlr.enable = false;

      extraPortals = lib.mkForce [
        pkgs.gnome.gnome-keyring
        pkgs.xdg-desktop-portal-hyprland
      ];
    };
  };
}
