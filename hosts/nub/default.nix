{ config
, pkgs
, lib
, inputs
, ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  services.keymapper.enable = true;
  services.power-profiles-daemon.enable = true;

  disko.devices = (import ./disko.nix {
    disk = "nvme-eui.00a075013ca91384";
  }).disko.devices;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [ ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernel.sysctl = {
    "vm.max_map_count" = 1048576;
    "vm.laptop_mode" = 5;
    "vm.dirty_writeback_centisecs" = 1500;
  };

  security.polkit.enable = true;
  services.mullvad-vpn.enable = true;
  programs.noisetorch.enable = true;

  services.udev = {
    enable = true;
    extraRules = ''
      # Disable power/wakeup for ELAN touchpad that prevents suspending.
      SUBSYSTEM=="i2c", DRIVER=="i2c_hid_acpi", ATTR{name}=="ELAN*", ATTR{power/wakeup}="disabled"
      # Limit battery max charge to 86% (85 in reality)
      ACTION=="add", SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_NAME}=="BAT0", ATTR{charge_control_start_threshold}="83", ATTR{charge_control_end_threshold}="86"
      # Allow anyone to change mic led
      SUBSYSTEM=="leds", KERNEL=="platform::micmute", RUN{program}+="${pkgs.coreutils-full}/bin/chmod a+rw /sys/devices/platform/thinkpad_acpi/leds/platform::micmute/brightness"
      # Allow anyone to change screen backlight
      ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="amdgpu_bl0", RUN{program}+="${pkgs.coreutils-full}/bin/chmod a+rw /sys/class/backlight/%k/brightness"
    '';
  };

  services.usbguard = {
    enable = true;

    IPCAllowedUsers = [ "root" "lillecarl" ];
    implicitPolicyTarget = "allow"; # Allow everything
  };

  services.btrbk.instances."btrbk" = {
    onCalendar = "*:0/15";
    settings = {
      snapshot_preserve_min = "2d";
      volume."/" = {
        #subvolume = "/home";
        snapshot_dir = ".snapshots";
      };
    };
  };

  services.acpid = {
    enable = true;
  };

  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  # Make some extra kernel modules available to NixOS
  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback.out
    usbip
    zenpower
    turbostat
    cpupower
  ];
  boot.blacklistedKernelModules = [
    "acpi_cpufreq"
    "ip_tables"
    "iptable_nat"
    "iptable_filter"
    "ip_set"
  ];

  # Activate kernel modules (choose from built-ins and extra ones)
  boot.kernelModules = [
    # Virtual Camera
    "v4l2loopback"
    # Virtual Microphone, built-in
    #"snd-aloop"
    "tp_smapi"
    "k10temp"
  ];

  # Set initial kernel module settings
  boot.extraModprobeConfig = ''
    # exclusive_caps: Skype, Zoom, Teams etc. will only show device when actually streaming
    # card_label: Name of virtual camera, how it'll show up in Skype, Zoom, Teams
    # https://github.com/umlaeute/v4l2loopback
    options v4l2loopback exclusive_caps=1 card_label="Virtual Camera"
  '';

  hardware = {
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

  services.blueman.enable = true;

  powerManagement = {
    enable = true;
    powertop.enable = true;
    cpuFreqGovernor = "schedutil";
  };

  services.gnome.gnome-keyring.enable = true;
  programs.seahorse.enable = true;

  nixpkgs = {
    # Allow proprietary software to be installed
    config.allowUnfree = true;
  };

  networking = rec {
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
  # Enable systemd-resolved, takes care of splitting DNS across interfaces n stuff
  services.resolved = {
    enable = true;

    fallbackDns = [
      "1.1.1.1"
      "1.0.0.1"
      "2606:4700:4700::1111"
      "2606:4700:4700::1001"
    ];
  };
  systemd.network = {
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

  # CUPS for printing documents.
  services.printing.enable = false;
  # Enable GlobalProtect VPN
  services.globalprotect.enable = true;

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
    waydroid.enable = true;
  };


  environment.systemPackages = with pkgs; [
    amdgpu_top
    gnome.gnome-keyring
    gnome.seahorse
    polkit-kde-agent
    catppuccin-cursors.macchiatoPink
    sbctl # sb = secure boot
    config.boot.kernelPackages.zenpower # zenpower
    winbox # MikroTik winbox, until we're rid of this crap at work.
    #splunk-otel-collector # Temp testing
    screen # Just for TTY
    acme-dns # ACME-DNS server. For certifying things that are behind corp firewall.
    usbguard # USB blocking solution
    k3s # Kubernetes K3s
    iptables # Give us the iptables CLI (should map to nftables)
    zenmonitor # AMD CPU monitoring
    virt-manager # Virtualisation manager
    virt-manager-qt # Shitty version of virt-manager
    distrobox # Run different distros on your machine
    openstackclient # OpenStack CLI client
    kde-gtk-config # KDE GTK Stuff (https://nixos.wiki/wiki/KDE)
    globalprotect-openconnect # GlobalProtect VPN for NENT
    qpaeq # Pulse Equalizer
    gcc11 # GNU Compiler Collection
    # Kernel modules with userspace commands
    config.boot.kernelPackages.cpupower
    config.boot.kernelPackages.turbostat
    config.boot.kernelPackages.usbip
  ];

  systemd = {
    # upower systemd service
    services.upower.enable = true;

    services.systemd-networkd-wait-online.enable = false;
  };

  # Enables upower daemon
  services.upower.enable = true;
  # TODO configure this to relay messages out on the internet too
  services.postfix = {
    enable = true;
    setSendmail = true;
  };

  system.stateVersion = "23.11";
}
