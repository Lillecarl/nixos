{ pkgs
, ...
}:
{
  services.auto-cpufreq = {
    enable = true;

    settings = {
      charger = {
        governor = "schedutil";
        turbo = "always";

        scaling_min_freq = 1089000;
        scaling_max_freq = 4768000;
      };

      battery = {
        governor = "schedutil";
        turbo = "always";

        scaling_min_freq = 400000;
        scaling_max_freq = 2700000;

        enable_thresholds = true;

        start_threshold = 80;
        stop_threshold = 86;
      };
    };
  };

  systemd.services.auto-cpufreq.path = [ pkgs.getent ];
}
