{ self
, pkgs
, ...
}@allArgs:
let
  swaylock = "${pkgs.swaylock}/bin/swaylock";
in
{
  services.swaync = {
    enable = true;
    systemdTarget = "hyprland-session.target";
  };

  programs.swaylock = {
    enable = true;

    settings = {
      daemonize = true;
      image = "${self}/resources/lockscreen.jpg";
      scaling = "center";
      color = "000000";
    };
  };

  services.swayidle = {
    enable = true;

    systemdTarget = "hyprland-session.target";

    events =
      if allArgs.systemConfig.networking.hostName == "nub" then [
        { event = "before-sleep"; command = swaylock; }
        { event = "lock"; command = swaylock; }
      ] else [ ];

    timeouts = [
      { timeout = 300; command = swaylock; }
      { timeout = 600; command = "${pkgs.hyprland}/bin/hyprctl dispatch dpms off"; }
    ];
  };
}
