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
      enable = true;
      wlr.enable = false;

      extraPortals = lib.mkForce [
        pkgs.gnome.gnome-keyring
        pkgs.xdg-desktop-portal-gtk
      ];
      config = {
        common = {
          default = [
            "gtk"
          ];
          "org.freedesktop.impl.portal.ScreenCast" = [
            "hyprland"
          ];
          "org.freedesktop.impl.portal.Screenshot" = [
            "hyprland"
          ];
          "org.freedesktop.impl.portal.GlobalShortcuts" = [
            "hyprland"
          ];
        };
      };
    };
  };
}
