{ config
, pkgs
, lib
, ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../common/k3s.nix
    ../common/postgresql.nix
    ../nixos/config/adb.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [ "resume=/dev/vg1/swap" "mem_sleep_default=deep" ];
  boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;
  #boot.kernel.sysctl = {
  #  "vm.swappiness" = 1;
  #};

  networking.ifupdown2 = {
    enable = true;

    extraPackages = [
      pkgs.bridge-utils
      pkgs.dpkg
      pkgs.ethtool
      pkgs.iproute2
      pkgs.kmod
      pkgs.mstpd
      pkgs.openvswitch
      pkgs.ppp
      pkgs.procps
      pkgs.pstree
      pkgs.service-wrapper
      pkgs.systemd
    ];

    extraConfig = ''
      auto ifbr0
      iface ifbr0
          bridge-pvid 1
          bridge-vids 100 200
          bridge-vlan-aware yes
          address 10.255.255.1/24
    '';
  };

  services.tp-auto-kbbl = {
    enable = true;
    device = "/dev/input/by-path/platform-i8042-serio-0-event-kbd";
    arguments = [
      "-b 1"
      "-t 2"
    ];
  };

  services.udev = {
    enable = true; #default
    extraRules = ''
      # Disable power/wakeup for ELAN touchpad that prevents suspending.
      SUBSYSTEM=="i2c", DRIVER=="i2c_hid_acpi", ATTR{name}=="ELAN*", ATTR{power/wakeup}="disabled"
      # Enable waking up by the keyboard, this doesn't work but if some FW changes some day it might.
      SUBSYSTEM=="serio", DRIVERS=="atkbd", ATTR{power/wakeup}="enabled"
      # Limit battery max charge to 86% (85 in reality)
      ACTION=="add|change", SUBSYSTEM=="acpi", DRIVER=="battery", ATTR{power_supply/BAT0/charge_control_end_threshold}="86"
    '';
  };

  services.usbguard = {
    enable = true;

    IPCAllowedUsers = [ "root" "lillecarl" ];
    implictPolicyTarget = "allow"; # Allow everything
  };

  services.salt = rec {
    master = {
      enable = true;

      configuration = {
        log_level = "debug";
        mine_interval = 1;
        file_roots = {
          base = [ "/srv/salt/salt" ];
        };
        pillar_roots = {
          base = [ "/srv/salt/pillar" ];
        };
        master_roots = {
          base = [ "/srv/salt/salt-master" ];
        };
        ext_pillar = [
          {
            file_tree = {
              root_dir = "/srv/salt/pillar/";
              render_default = "jinja|yaml";
              template = true;
            };
          }
        ];
      };
    };
    minion = {
      enable = true;

      configuration =
        master.configuration
        // {
          master = "127.0.0.1";
        };
    };
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

    handlers = {
      mic-led = {
        action = ''
                vals=($1)  # space separated string to array of multiple values
                case ''${vals[1]} in
                    F20)
                 if ${pkgs.systemd}/bin/machinectl shell lillecarl@ ${pkgs.pulseaudio}/bin/pactl get-source-mute alsa_input.pci-0000_05_00.6.HiFi__hw_acp__source | ${pkgs.gnugrep}/bin/grep "Mute: yes"
          then
                   echo 1 > /sys/class/leds/platform::micmute/brightness
          else
                   echo 0 > /sys/class/leds/platform::micmute/brightness
          fi
                        ;;
                    *)
                        echo unknown >> /tmp/acpi.log
                        ;;
                esac
        '';
        event = "button/*";
      };
    };
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
  boot.blacklistedKernelModules = [ "acpi_cpufreq" ];

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

  powerManagement = {
    enable = true;
    powertop.enable = true;
    cpuFreqGovernor = "schedutil";
  };

  services.gnome.gnome-keyring.enable = true;

  nixpkgs = {
    # Allow proprietary software to be installed
    config.allowUnfree = true;
  };

  networking = rec {
    hostName = "nub"; # System hostname
    domain = "viaplay.io"; # System domain
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

  programs.kdeconnect.enable = true;

  environment.systemPackages = with pkgs; [
    xwaylandvideobridge # xwayland video bridge
    kdeconnect # Utility for connecting smartphone with KDE.
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

  environment.shellInit = ''
    export GTK_PATH=$GTK_PATH:${pkgs.libsForQt5.breeze-gtk}/lib/gtk-2.0
    export GTK2_RC_FILES=$GTK2_RC_FILES:${pkgs.libsForQt5.breeze-gtk}/share/themes/breeze-gtk/gtk-2.0/gtkrc
  '';

  systemd = {
    # upower systemd service
    services.upower.enable = true;

    services.systemd-networkd-wait-online.enable = false;

    services.before-sleep = {
      enable = true;
      wantedBy = [ "sleep.target" ];
      before = [ "sleep.target" ];
      script = ''
               ${pkgs.procps}/bin/pgrep gpclient | xargs kill
        ${pkgs.iproute2}/bin/ip link del tun0
      '';
    };
  };

  # Enables upower daemon
  services.upower.enable = true;
  # TODO configure this to relay messages out on the internet too
  services.postfix = {
    enable = true;
    setSendmail = true;
  };

  system.stateVersion = "22.05";
}
