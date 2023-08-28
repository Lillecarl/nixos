{ ... }:
{
  services.tlp = {
    enable = true;

    settings = {
      # Always powersave to not run fans too hard
      CPU_SCALING_GOVERNOR_ON_AC = "powersave";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      # Balance speed differently on AC and power
      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";
      # Different platform profile
      PLATFORM_PROFILE_ON_AC = "performance";
      PLATFORM_PROFILE_ON_BAT = "low-power";
      # Don't boost on battery
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;
      # Set cpu opmode
      CPU_DRIVER_OPMODE_ON_AC = "active";
      CPU_DRIVER_OPMODE_ON_BAT = "guided";
      # Set GPU power targets
      RADEON_DPM_PERF_LEVEL_ON_AC = "balanced";
      RADEON_DPM_PERF_LEVEL_ON_BAT = "battery";
      # Don't charge to 100% to save battery from early death
      START_CHARGE_THRESH_BAT0 = 80;
      STOP_CHARGE_THRESH_BAT0 = 85;
      # Don't exclude printers from autosuspend
      USB_EXCLUDE_PRINTER = 0;
    };
  };
}
