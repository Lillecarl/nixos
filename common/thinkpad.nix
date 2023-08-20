{ inputs
, pkgs
, ...
}:
{
  services.thinkfan = {
    enable = false;
  };

  services.tp-auto-kbbl = {
    enable = true;
    device = "/dev/input/by-path/platform-i8042-serio-0-event-kbd";
    arguments = [
      "-b 1"
      "-t 2"
    ];
  };
}
