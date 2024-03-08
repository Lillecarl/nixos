{ lib, ... }:
{
  systemd = {
    # Run tp-auto-kbbl after keymapper.service
    services.tp-auto-kbbl.partOf = [ "remapper.service" ];
    services.tp-auto-kbbl.unitConfig.After = lib.mkForce [ "remapper.service" ];
  };

  services = {
    tp-auto-kbbl = {
      enable = true;
      device = "/dev/input/pykbd";
      arguments = [
        "-b 1"
        "-t 2"
      ];
    };

    udev.extraRules = /* udev */ ''
      #ACTION="add", SUBSYSTEM=="leds", KERNEL=="platform::micmute" ATTR{trigger}="audio-micmute"
    '';
  };
}
