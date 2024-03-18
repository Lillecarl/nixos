{ config
, pkgs
, ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  carl = {
    remapper = {
      enable = true;
      keyboardName = "AT Translated Set 2 keyboard";
    };
  };

  disko.devices = (import ./disko.nix {
    disk = "nvme-eui.00a075013ca91384";
  }).disko.devices;

  programs.noisetorch.enable = true;

  security = {
    polkit.enable = true;
    tpm2 = {
      enable = true;
    };
  };

  systemd = {
    # Disable stuff that never works
    targets.hibernate.enable = false;
    targets.hybrid-sleep.enable = false;

    network = {
      enable = true;

      wait-online = {
        enable = false;
        timeout = 5;
        anyInterface = true;
      };

      netdevs = {
        lilbr = {
          netdevConfig = {
            Kind = "bridge";
            Name = "lilbr";
            MTUBytes = "1500";
            MACAddress = "44:38:39:36:EA:D5";
          };
        };
      };
      networks = {
        lilbr = {
          address = [ "10.255.255.1/24" ];
          networkConfig = {
            LLDP = true;
            EmitLLDP = true;
            MulticastDNS = true;
          };
          dhcpServerConfig = {
            ServerAddress = "10.255.255.1/24";
            PoolOffset = 50;
            EmitDNS = true;
            DNS = "10.255.255.1";
          };
          linkConfig = {
            ActivationPolicy = "always-up";
          };
        };
      };
    };
  };

  services = {
    # BT mgmt
    blueman.enable = true;
    logind =
      let
        watdo = "suspend";
      in
      {
        hibernateKey = watdo;
        hibernateKeyLongPress = watdo;
        powerKey = watdo;
        powerKeyLongPress = watdo;
        suspendKey = watdo;
        suspendKeyLongPress = watdo;
        rebootKey = watdo;
        rebootKeyLongPress = watdo;
      };
    # DBUS for power management
    upower.enable = true;
    # TODO configure this to relay messages out on the internet too
    postfix = {
      enable = true;
      setSendmail = true;
    };
    mullvad-vpn.enable = true;
    udev =
      let
        coreutilsb = "${pkgs.coreutils-full}/bin";
      in
      {
        enable = true;
        packages = [
          pkgs.ddcutil
        ];
        extraRules = /* udev */ ''
          # Disable power/wakeup for ELAN touchpad that prevents suspending.
          SUBSYSTEM=="i2c", DRIVER=="i2c_hid_acpi", ATTR{name}=="ELAN*", ATTR{power/wakeup}="disabled"
          # Limit battery max charge to 86% (85 in reality)
          ACTION=="add", SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_NAME}=="BAT0", ATTR{charge_control_start_threshold}="83", ATTR{charge_control_end_threshold}="86"
          # Allow anyone to change mic led
          SUBSYSTEM=="leds", KERNEL=="platform::micmute", RUN{program}+="${coreutilsb}/chmod a+rw /sys/devices/platform/thinkpad_acpi/leds/platform::micmute/brightness"
          SUBSYSTEM=="leds", KERNEL=="platform::micmute", RUN{program}+="${pkgs.miconoff} 0"
          # Allow anyone to change screen backlight
          ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="amdgpu_bl0", RUN{program}+="${coreutilsb}/chmod a+rw /sys/class/backlight/%k/brightness"
        '';
      };

    usbguard = {
      enable = true;

      IPCAllowedUsers = [ "root" "lillecarl" ];
      implicitPolicyTarget = "allow"; # Allow everything
    };

    btrbk.instances."btrbk" = {
      onCalendar = "*:0/15";
      settings = {
        snapshot_preserve_min = "2d";
        volume."/" = {
          #subvolume = "/home";
          snapshot_dir = ".snapshots";
        };
      };
    };

    acpid = {
      enable = true;
    };

    gnome.gnome-keyring.enable = true;

    # Enable systemd-resolved, takes care of splitting DNS across interfaces n stuff
    resolved = {
      enable = true;

      fallbackDns = [
        "1.1.1.1"
        "1.0.0.1"
        "2606:4700:4700::1111"
        "2606:4700:4700::1001"
      ];
    };
  };

  boot = {
    # Build rpi images
    binfmt.emulatedSystems = [ "aarch64-linux" ];
    # Use the systemd-boot EFI boot loader.
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    kernelParams = [ ];
    kernelPackages = pkgs.linuxPackages_latest;
    kernel.sysctl = {
      "vm.max_map_count" = 1048576;
      "vm.laptop_mode" = 5;
      "vm.dirty_writeback_centisecs" = 1500;
    };
    # Make some extra kernel modules available to NixOS

    # Activate kernel modules (choose from built-ins and extra ones)
    kernelModules = [
      # Virtual Camera
      "v4l2loopback"
      # Virtual Microphone, built-in
      #"snd-aloop"
      "tp_smapi"
      "k10temp" # This shouldn't be here
    ];

    # Set initial kernel module settings
    extraModprobeConfig = ''
      # exclusive_caps: Skype, Zoom, Teams etc. will only show device when actually streaming
      # card_label: Name of virtual camera, how it'll show up in Skype, Zoom, Teams
      # https://github.com/umlaeute/v4l2loopback
      options v4l2loopback exclusive_caps=1 card_label="Virtual Camera"
    '';
  };

  hardware = {
    i2c.enable = true;

    bluetooth = {
      enable = true;

      powerOnBoot = true;

      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
        };
      };
    };
    enableRedistributableFirmware = true;
  };


  powerManagement = {
    enable = true;
    powertop.enable = true;
    cpuFreqGovernor = "schedutil";
  };

  programs.seahorse.enable = true;

  nixpkgs = {
    # Allow proprietary software to be installed
    config.allowUnfree = true;
  };

  networking = {
    hostName = "nub"; # System hostname
    domain = "helicon.ai"; # System domain
    nftables.enable = true; # Enable nftables
    firewall.enable = false; # Disable iptables
    networkmanager = {
      enable = true; # Laptops do well with networkmanager
      unmanaged = [ "virbr0" "lilbr" ];
    };
    useDHCP = false; # deprecated, should be false

    hosts = { };
  };

  # CUPS for printing documents.
  services.printing.enable = false;

  virtualisation = {
    libvirtd = {
      enable = true;
    };
    lxd = {
      enable = false;
      recommendedSysctlSettings = true;
    };
    #lxc.lxcfs.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
    };
  };


  environment.systemPackages = with pkgs; [
    # Kernel modules with userspace commands
    amdgpu_top
    config.boot.kernelPackages.cpupower
    config.boot.kernelPackages.turbostat
    config.boot.kernelPackages.usbip
    config.boot.kernelPackages.zenpower # zenpower
    distrobox # Run different distros on your machine
    gnome.gnome-keyring
    gnome.seahorse
    iptables # Give us the iptables CLI (should map to nftables)
    k3s # Kubernetes K3s
    polkit-kde-agent
    qpaeq # Pulse Equalizer
    sbctl # sb = secure boot
    screen # Just for TTY
    usbguard # USB blocking solution
    virt-manager # Virtualisation manager
    virt-manager-qt # Shitty version of virt-manager
    zenmonitor # AMD CPU monitoring
  ];


  system.stateVersion = "24.05";
}
