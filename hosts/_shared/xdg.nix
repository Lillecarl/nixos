{ pkgs
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

      extraPortals = [
        pkgs.gnome-keyring
        pkgs.xdg-desktop-portal-gtk
        pkgs.xdg-desktop-portal-gnome
      ];
      config = {
        common = {
          default = [
            "gtk"
          ];
        };
      };
    };
  };
}
