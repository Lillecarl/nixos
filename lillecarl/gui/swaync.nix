{ pkgs
, bp
, ...
}:
{
  systemd.user.services.swaync = {
    Unit = {
      Description = "Sway notification center";
    };
    Service = {
      ExecStart = bp pkgs.swaynotificationcenter;
    };
    Install = {
      WantedBy = [ "hyprland-session.target" ];
    };
  };
}
