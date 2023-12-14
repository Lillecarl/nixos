{ lib, ... }:
{
  systemd.services.thinkfan.enable = false;

  services.thinkfan = {
    enable = true;
  };

  services.tp-auto-kbbl = {
    enable = true;
    device = "/dev/input/keymapper_kb";
    arguments = [
      "-b 1"
      "-t 2"
    ];
  };

  services.udev.extraRules = /* udev */ ''
    ACTION="add", SUBSYSTEM=="leds", KERNEL=="platform::micmute" ATTR{trigger}="audio-micmute"
  '';

  # Run tp-auto-kbbl after keymapper.service
  systemd.services.tp-auto-kbbl.partOf = [ "keymapper.service" ];
  systemd.services.tp-auto-kbbl.unitConfig.After = lib.mkForce [ "keymapper.service" ];
}
