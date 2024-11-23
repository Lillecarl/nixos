{ lib, config, pkgs, ... }:
{
  systemd.user.services.xdg-user-data-dirs = lib.mkIf config.ps.terminal.enable {
    Unit = {
      Description = "Configure XDG user dirs";
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.xdg-user-dirs}/bin/xdg-user-dirs-update";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
