{ pkgs, ... }:
{
  systemd.user.services.swaync = {
    Unit = {
      Description = "Sway notification center";
    };
    Service = {
      ExecStart = "${pkgs.swaynotificationcenter}/bin/swaync";
    };
    Install = {
      WantedBy = [ "hyprland-session.target" ];
    };
  };
}
