{ self
, pkgs
, ...
}:
let
  swaylock = "${pkgs.swaylock}/bin/swaylock";

  writePython3 = import ../../lib/writePython3.nix { inherit pkgs; };

  swaysleep = writePython3 "swaysleep"
    {
      libraries = [ pkgs.python3.pkgs.plumbum ];
      flakeIgnore = [ "E501" ]; # Lines too long when rendering Nix paths
    }
    (
      builtins.replaceStrings
        [ "\"systemctl\"" ]
        [ "\"${pkgs.systemd}/bin/systemctl\"" ]
        (builtins.readFile ./swaysleep.py)
    );
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
