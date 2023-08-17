{ self
, pkgs
, ...
}:
let
  swaylock = "${pkgs.swaylock}/bin/swaylock";
  writePython3 = name: attrs: script: let
    scriptHead = builtins.head (builtins.split "\n" script);
    finalScriptString = builtins.replaceStrings [ scriptHead ] [ "" ] script;
  in
    pkgs.writers.writePython3 name attrs finalScriptString;

  swaysleep = writePython3 "swaysleep"
    {
      libraries = [ pkgs.python3.pkgs.plumbum ];
      flakeIgnore = [ "E501" ]; # Lines too long when rendering Nix paths
    }
    (builtins.replaceStrings
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
      # I can be very forgetful at times
      { timeout = 1800; command = "${swaysleep}"; }
      { timeout = 3600; command = "${swaysleep}"; }
      { timeout = 7200; command = "${swaysleep}"; }
    ];
  };
}
