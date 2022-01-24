# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
{
  imports = [
    # Import hardware configuration
    ./hardware-configuration.nix
    # Import boot configuration 
    ./boot.nix
    # Configuration shared between all hosts
    ../common
  ];


  nixpkgs = {
    # Allow proprietary software to be installed
    config.allowUnfree = true;
  };

  nix = {
    package = pkgs.nixFlakes;
    autoOptimiseStore = true;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };


  # Networking, virbr0 is WAN iface
  networking = {
    hostName = "shitbox";
    hostId = "43211234";
    #useNetworkd = true;
    useDHCP = false;
    #nameservers = [ "1.1.1.1" ];
    #bridges.virbr0.interfaces = [ "eno1" ];
    #interfaces.eno1.useDHCP = false;
    #interfaces.virbr0.useDHCP = true;
    networkmanager = {
      enable = true;
      unmanaged = [ "virbr0" "lxdbr0" ];
    };
  };

  services = {
    xserver = {
      # Enable the Plasma 5 Desktop Environment.
      enable = true;
      displayManager.sddm.enable = true;
      desktopManager.plasma5.enable = true;
      # Keyboard layout
      layout = "us";
      # Use NVIDIA driver
      videoDrivers = [ "nvidia" ];
    };
    ratbagd = {
      enable = true;
    };
    zfs = {
      autoSnapshot = {
        enable = true;
        frequent = 8;
        monthly = 1;
      };
    };
    # Enable TOR
    tor = {
      enable = true;
      client = {
        enable = true;
      };
    };
    # Enable SSD trimming
    fstrim = {
      enable = true;
    };
    # Run sound through pipewire
    pipewire = {
      enable = true;
      #alsa.enable = true;
      #alsa.support32Bit = true;
      #jack.enable = true;
      pulse.enable = true;
      socketActivation = true;
    };
    ntp = {
      enable = true;
      servers = [
        "0.se.pool.ntp.org"
        "1.se.pool.ntp.org"
        "2.se.pool.ntp.org"
        "3.se.pool.ntp.org"
      ];
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    pciutils
    qemu_kvm
    dmidecode
    ksnip
    #tridactyl-native
    lshw
    bridge-utils
    qtcreator
    units
    heroku
    libreoffice
    piper
    syncthing
    nmap
    obs-studio
    gwenview
    okular
    virt-manager
    OVMFFull
    numactl
    looking-glass-client
    barrier
    etcher
    ark
    archiver
    libarchive
    discord
    teamspeak_client
    lutris
    appimage-run # running appimages (shadow)

    # Hardware management
    smartmontools
    ddcutil # Monitor control
  ];

  environment.etc = {
    "X11/xorg.conf.d/90-nvidia-i2c.conf" = {
      source = "${pkgs.ddcutil}/share/ddcutil/data/90-nvidia-i2c.conf";
    };
  };

  virtualisation = {
    libvirtd = {
      enable = true;
      extraConfig = ''
        user="lillecarl"
      '';

      qemu = {
        package = pkgs.qemu_kvm;
        ovmf = {
          enable = true;
          package = pkgs.OVMFFull;
        };

        swtpm = {
          enable = true;
        };

        verbatimConfig = ''
          namespaces = []
          user = "+1000"
        '';
      };
    };
    lxd = {
      enable = true;
      zfsSupport = true;
      recommendedSysctlSettings = true;
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?
}

