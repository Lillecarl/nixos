{ inputs
, config
, pkgs
, lib
, programs-sqlite-db
, ...
}:
let
  pkgs-overlay = import ../pkgs;
in
rec
{
  nixpkgs.overlays = [
    pkgs-overlay
    #inputs.nixpkgs-wayland.overlay
    inputs.nur.overlay
  ];

  environment.systemPackages = with pkgs; [
    home-manager
    vim
    git
  ];

  programs.zsh.enable = true;
  programs.nix-ld.enable = true;

  # XDG Base Directory Specification
  environment.sessionVariables = rec {
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
    FLAKE = "/home/lillecarl/Code/nixos"; # for use with "nh"
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
  # Allow root to map to LilleCarl user in LXD container
  users.users.root = {
    subUidRanges = [
      {
        count = 1;
        startUid = users.users.lillecarl.uid;
      }
    ];
    subGidRanges = [
      {
        count = 1;
        startGid = 1000;
      }
    ];
  };

  users.defaultUserShell = pkgs.zsh;
  users.users.lillecarl = {
    uid = 1000;
    #shell = "${pkgs.xonsh}/bin/xonsh";
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "libvirtd"
      "networkmanager"
      "lxd"
      "flatpak"
      "adbusers"
      "podman"
      "wireshark"
      "i2c"
      "video"
    ];
  };

  # Make command not found suggest nix derivations
  programs.command-not-found.dbPath = programs-sqlite-db;
  # Enable IO perf monitoring
  programs.iotop.enable = true;
}
