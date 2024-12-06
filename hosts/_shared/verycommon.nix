{
  pkgs,
  config,
  flakeloc,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    home-manager
  ];

  programs.git = {
    enable = true;
  };

  security.sudo.wheelNeedsPassword = true;

  programs = {
    zsh.enable = true;
    # Enable IO perf monitoring
    iotop.enable = true;
  };

  # XDG Base Directory Specification
  environment.sessionVariables = {
    NODE_HOME = "\${HOME}/.local/node";
    POWERSHELL_TELEMETRY_OPTOUT = "yes"; # No powershell telemetry
    NIXOS_OZONE_WL = "1"; # Use Wayland whenever we can
    PIP_DISABLE_PIP_VERSION_CHECK = "1"; # Disable pip version warnings
    FLAKE = flakeloc;
    HOST = config.networking.hostName;
  };

  services.fstrim.enable = true;

  # Give applications 15 seconds to shut down when shutting down the computer
  systemd.extraConfig = ''
    DefaultTimeoutStopSec=15s
  '';

  # Tailscale exit-node & subnet routing fix (asym routing)
  networking.firewall.checkReversePath = "loose";

  # Set your time zone.
  time.timeZone = "Europe/Stockholm";

}
