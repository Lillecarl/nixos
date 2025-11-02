{
  lib,
  config,
  pkgs,
  ...
}:
let
  modName = "xdg";
  cfg = config.ps.${modName};
in
{
  options.ps = {
    ${modName} = {
      enable = lib.mkOption {
        default = config.ps.workstation.enable;
        description = "Whether to enable ${modName}.";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.xdg-utils
    ];

    xdg = {
      portal = {
        enable = true;
        # wlr.enable = false;

        # extraPortals = [
        #   pkgs.xdg-desktop-portal-gtk
        #   pkgs.xdg-desktop-portal-gnome
        # ];
        # config = {
        #   common = {
        #     default = [
        #       "gtk"
        #     ];
        #   };
        # };
      };
    };
  };
}
