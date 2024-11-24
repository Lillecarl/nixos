{ lib, config, ... }:
{
  config = lib.mkIf config.ps.gui.enable {
    services.udiskie = {
      enable = true;
      automount = false;
    };

    systemd.user.services.udiskie = {
      Unit = {
        After = lib.mkForce [
          "graphical-session-pre.target"
          "waybar.service"
        ];
        Requires = lib.mkForce [ "waybar.service" ];
      };
    };
  };
}
