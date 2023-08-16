{ self
, pkgs
, ...
}:
let
  swaylock = "${pkgs.swaylock}/bin/swaylock";
  swaysleep = pkgs.writers.writePython3 "swaysleep"
    {
      libraries = [ pkgs.python3.pkgs.plumbum ];
      flakeIgnore = [ "E501" ]; # Lines too long when rendering Nix paths
    }
    ''
      from pathlib import Path
      from plumbum import local

      systemctl = local["${pkgs.systemd}/bin/systemctl"]

      # Contains status about our laptop battery
      batstat = Path("/sys/class/power_supply/BAT0/status").read_text()

      if batstat.find("Discharging") != -1:
          print("Suspending")
          systemctl(["suspend"])
      else:
          print("Not suspending, we're not discharging")
    '';
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
      # I can be very forgetful at times
      { timeout = 1800; command = "${swaysleep}"; }
      { timeout = 3600; command = "${swaysleep}"; }
      { timeout = 7200; command = "${swaysleep}"; }
    ];
  };
}
