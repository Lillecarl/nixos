{ self
, pkgs
, lib
, bp
, systemConfig
, ...
}@allArgs:
{
  services.swaync = {
    enable = true;
    systemdTarget = "hyprland-session.target";

    settings = {
      layer = "overlay";
      positionX = "right";
      positiony = "center";
      hide-on-clear = true;
      layer-shell = true;
    };
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
        { event = "before-sleep"; command = bp pkgs.swaylock; }
        { event = "lock"; command = bp pkgs.swaylock; }
      ] else [ ];

    timeouts = [
      { timeout = 300; command = bp pkgs.swaylock; }
      ((lib.mkIf (systemConfig.networking.hostName == "shitbox")) { timeout = 600; command = "${pkgs.hyprland}/bin/hyprctl dispatch dpms off"; })
    ];
  };
}
