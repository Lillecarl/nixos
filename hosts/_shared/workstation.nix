{
  lib,
  config,
  pkgs,
  ...
}:
let
  modName = "workstation";
  cfg = config.ps.${modName};
in
{
  options.ps = {
    ${modName} = {
      enable = lib.mkOption {
        default = false;
        description = "Whether to enable ${modName}.";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    hardware.uinput.enable = true;
    programs = {
      # Enable wireshark
      wireshark.enable = true;
      # dconf is good i guess
      dconf.enable = true;
    };
    environment = {
      enableDebugInfo = true;
    };
    security = {
      # Pluggable Authentication Modules (PAM)
      pam.services =
        let
          service = {
            enableGnomeKeyring = true;
            failDelay = {
              enable = true;
              delay = 100000; # 100 ms
            };
          };
        in
        {
          login = service;
          swaylock = service;
          passwd = service;
        };
    };

    environment.systemPackages = with pkgs; [
      # Commandline tools (CLI)
      virtiofsd # VirtIO filesystem daemon
      home-manager # Tool to build your home environment in a reproducible fashion, anywhere with Nix!
      rmtrash # rm compatible remove tool
      inetutils # Common internet utilities
      tcpdump # Network packet analyzer / cap tool
      nmap # Network scanner
      execline # Tools for dbus n stuff
      handlr # xdg-open alternative
      asciinema # Terminal session recorder
      wireguard-tools # Wireguard tools
      pmutils # Suspend tools
      inotify-tools # CLI tools for inotify in Linux
      inotify-info # inotify troubleshooter helper
      sshfs # Mount SFTP as filesystem
      rclone # rsync for clouds (+ loads of other cool things)
      gnumake # make
      sipcalc # Subnet calculator
      dogdns # dig without poop
      whois # whois command
      (lowPrio wireshark-cli) # Wireshark CLI
      (lowPrio termshark) # Wireshark TUI?
      entr # Run commands when files change
      pv # Monitor pipe progress
      libnotify # Cli utils for sending KDE notifications
      vim # Modal CLI text editor
      neovim # Modal CLI text editor, modern version of Vim
      lsof # Check who uses file
      wget # Fetch things quickly with HTTP
      gptfdisk # CLI partition management (GPT)
      efitools # Tools for managing EFI, variables and such
      curl # All things HTTP and other web transfer protocols
      tmux # terminal multiplexer
      htop # NCurses "task manager"
      bottom # Task Manager written in Rust
      powertop # See power information
      iotop # See disk IO information
      nixpkgs-fmt # Format Nix like the Nix project wants
      manix # Nix documentation search tool
      nix-index # Files database for nixpkgs (find uninstalled commands)
      nix-tree # visualize the Nix store interactively
      nix-update # Tool to help updating nix packages
      nix-prefetch # nix prefetcher
      nix-prefetch-github # fetch nix package from github
      pijul # Patch based git alternative (Similar to darcs but written in rust)
      gitui # Git TUI, rust
      wl-clipboard # Wayland clipboard manipulation
      iftop # Show interface throughput and which IP's
      smartmontools # Read SSD SMART information
      glances # Fancy system monitoring TUI
      lm_sensors # Read sensors
      file # Show information about files
      desktop-file-utils # Required for VS Code live share
      ncdu # NCurses Disk Utility (TUI way of finding big files and folders)
      scrot # Commandline print-screen tool, use with GnuPG for automatic screenshotting
      pulseaudio # For pactl
      dmidecode # system information
      pciutils # PCI(e) utilities (lspci for example)
      usbutils # USB utils
      bridge-utils # Bridge utils
      xdotool # Tools to automate mouse and keyboard in X
      wtype # Wayland version of xdotools
      libsForQt5.qt5.qttools # qdbus command comes from here
      tree # Show things as a CLI tree in folders
      neofetch # Tool for fancy print-screens
      bwm_ng # Check current network throughput by reading interface values
      killall # Kill processes by name
      swtpm # needed to emulate TPM on QEMU
      gnupg # PGP implementation
      nnn # file manager
      unipicker # unicode char finder
      waypipe # Wayland forwarding (Like X11 forwarding, but for Wayland)
      libinput # Libinput CLI tooling
      brightnessctl # Control brightness of things
      conntrack-tools # Connection tracking userspace tools
      iptstate # Conntrack "top like" tool
      nixos-generators # Tools for generating nixos images (AWS, Azure, ISO etc..)
      unzip # Decompress zip files
      unrar # Decompress rar files
      libressl # Crypto library, userspace tools
      fsql # Query the filesystem with SQL
      pstree # Show process tree as a tree
      gist # Tool to post files to gist.github.com straight away

      # System tools
      libhugetlbfs # Huge pages tooling

      # Misc
      wineWowPackages.waylandFull # Win32 API compatibility layer for Linux
    ];
    systemd = {
      # Enable out of memory daemon (killer) on all slices, we're a workstation
      oomd = {
        enableUserSlices = true;
        enableSystemSlice = true;
        enableRootSlice = true;
      };
      # Disable network-manager wait-online service that prohibits nixos-rebuild
      services.NetworkManager-wait-online.enable = false;
    };

    services = {
      # Enabled fwupd daemon, allows applications to update firmware
      fwupd.enable = true;
      # enable tailscale daemon
      tailscale.enable = true;
      # Local network autodiscovery services
      # required for chromecasting to work
      avahi = {
        nssmdns4 = true;
        enable = true;
        ipv4 = true;
        ipv6 = true;
        publish = {
          enable = true;
          addresses = true;
          workstation = true;
        };
      };
      # Enable Flatpak
      flatpak.enable = true;
      # Packages that can install udev rules
      udev.packages = [ ];
    };
    # Give applications 15 seconds to shut down when shutting down the computer
    systemd.extraConfig = ''
      DefaultTimeoutStopSec=15s
    '';
  };
}
