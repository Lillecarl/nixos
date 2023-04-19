{ config
, pkgs
, ...
}: {
  imports = [
    # Import hardware configuration
    ./hardware-configuration.nix
  ];

  disko.devices = import ./disko.nix { };

  nixpkgs = {
    # Allow proprietary software to be installed
    config.allowUnfree = true;
  };

  nix.buildMachines = [
    {
      hostName = "localhost";
      system = "x86_64-linux";
      supportedFeatures = [ "kvm" "nixos-test" "big-parallel" "benchmark" ];
      maxJobs = 8;
    }
  ];

  # Networking, virbr0 is WAN iface
  networking = {
    hostName = "shitbox";
    hostId = "43211234";
    useDHCP = false;
    networkmanager = {
      enable = true;
      unmanaged = [ "virbr0" "lxdbr0" ];
    };
    firewall.enable = false;
  };

  hardware.opengl.enable = true;
  hardware.opengl.driSupport32Bit = true;
  #hardware.opengl.extraPackages = with pkgs; [
  #  rocm-opencl-icd
  #  rocm-opencl-runtime
  #  amdvlk
  #];
  #hardware.opengl.extraPackages32 = with pkgs; [
  #  driversi686Linux.amdvlk
  #];

  services = {
    xserver = {
      # Enable the Plasma 5 Desktop Environment.
      enable = true;
      displayManager.sddm.enable = true;
      desktopManager.plasma5.enable = true;
      # Keyboard layout
      layout = "us";
      # Use AMD driver
      videoDrivers = [ "amdgpu" ];
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
    gnome.adwaita-icon-theme # Lutris icons
    virt-manager # Virtualisation manager
    virt-manager-qt # Shitty version of virt-manager
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
    ark
    archiver
    libarchive
    discord
    teamspeak_client
    appimage-run # running appimages (shadow)

    # Hardware management
    smartmontools
    ddcutil # Monitor control
  ];

  #environment.etc = {
  #  "X11/xorg.conf.d/90-nvidia-i2c.conf" = {
  #    source = "${pkgs.ddcutil}/share/ddcutil/data/90-nvidia-i2c.conf";
  #  };
  #};

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
          packages = [ pkgs.OVMFFull.fd pkgs.OVMFFull ];
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
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?
}
