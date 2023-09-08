{ pkgs
, lib
, ...
}:
{
  environment.systemPackages = [
    pkgs.xdg-utils
  ];

  xdg = {
    portal = {
      wlr.enable = false;

      extraPortals = lib.mkForce [
        pkgs.gnome.gnome-keyring
        pkgs.xdg-desktop-portal-gtk
        pkgs.xdg-desktop-portal-hyprland
      ];
    };
  };
}
