{ pkgs
, programs-sqlite-db
, flakeloc
, ...
}:
{
  environment.systemPackages = with pkgs; [
    home-manager
    vim
    git
  ];

  programs.zsh.enable = true;
  programs.nix-ld.enable = true;

  # XDG Base Directory Specification
  environment.sessionVariables = {
    XDG_CACHE_HOME = "\${HOME}/.cache";
    XDG_CONFIG_HOME = "\${HOME}/.config";
    XDG_BIN_HOME = "\${HOME}/.local/bin";
    XDG_DATA_HOME = "\${HOME}/.local/share";
    XDG_STATE_HOME = "\${HOME}/.local/state";
    NODE_HOME = "\${HOME}/.local/node";

    PATH = [
      "\${XDG_BIN_HOME}"
    ];

    POWERSHELL_TELEMETRY_OPTOUT = "yes"; # No powershell telemetry
    NIXOS_OZONE_WL = "1"; # Use Wayland whenever we can
    PIP_DISABLE_PIP_VERSION_CHECK = "1"; # Disable pip version warnings
    FLAKE = flakeloc;
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

  # Make command not found suggest nix derivations
  programs.command-not-found.dbPath = programs-sqlite-db;
  # Enable IO perf monitoring
  programs.iotop.enable = true;
}
