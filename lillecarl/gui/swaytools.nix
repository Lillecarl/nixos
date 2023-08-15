{ self
, pkgs
, ...
}:
let
  swaylock = "${pkgs.swaylock}/bin/swaylock";
in
{
  programs.swaylock = {
    enable = true;

    settings = {
      image = "${self}/resources/lockscreen.jpg";
      scaling = "center";
      color = "000000";
    };
  };

  services.swayidle = {
    enable = true;

    systemdTarget = "hyprland-session.target";

    events = [
      { event = "before-sleep"; command = swaylock; }
      { event = "lock"; command = swaylock; }
    ];

    timeouts = [
      { timeout = 300; command = swaylock; }
    ];
  };
}
