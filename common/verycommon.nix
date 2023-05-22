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

  nixpkgs.config.permittedInsecurePackages = [
    "nodejs-16.20.0"
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
  };

  services.fstrim.enable = true;

  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = ''
      experimental-features = nix-command flakes repl-flake
      builders-use-substitutes = true
    '';
    settings = {
      auto-optimise-store = true;
      trusted-users = [ "root" "lillecarl" ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
        "rycee.cachix.org-1:TiiXyeSk0iRlzlys4c7HiXLkP3idRf20oQ/roEUAh/A="
      ];
      substituters = [
        "https://cache.nixos.org"
        "https://cachix.cachix.org"
        "https://nix-community.cachix.org"
        "https://nixpkgs-wayland.cachix.org"
        "https://rycee.cachix.org"
      ];
    };
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
    buildMachines = [
      {
        hostName = "shitbox";
        sshUser = "lillecarl";
        system = "x86_64-linux";
        maxJobs = 1;
        speedFactor = 2;
        supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
        mandatoryFeatures = [ ];
      }
    ];
    distributedBuilds = true;
  };

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
