{ ... }:
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
}
