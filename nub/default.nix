# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:
let
  kubeEnable = false;
  kubeMasterIP = "192.168.122.1";
  kubeMasterHostname = "api.kube";
  kubeMasterAPIServerPort = 6443;

  prometheusEnable = true;
in
rec
{
  imports = [
    ./hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [ "resume=/dev/vg1/swap" "mem_sleep_default=deep" ];
  #boot.kernelPackages = with pkgs.linuxKernel.packages; linux_xanmod_latest;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  services.tp-auto-kbbl = {
    enable = true;
    arguments = [
      "-b 1"
      "-t 2"
    ];
  };

  services.salt.master = {
    enable = true;

    configuration = {
      file_roots = {
        base = [ "/srv/salt/salt" ];
      };
      pillar_roots = {
        base = [ "/srv/salt/pillar" ];
      };
      master_roots = {
        base = [ "/srv/salt/salt-master" ];
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
  ];

  # Activate kernel modules (choose from built-ins and extra ones)
  boot.kernelModules = [
    # Virtual Camera
    "v4l2loopback"
    # Virtual Microphone, built-in
    #"snd-aloop"
    "tp_smapi"
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
    cpuFreqGovernor = "powersave";
  };

  services.gnome.gnome-keyring.enable = true;

  nix.settings.auto-optimise-store = true;

  nixpkgs = {
    # Allow proprietary software to be installed
    config.allowUnfree = true;
  };

  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  networking = {
    hostName = "nub"; # System hostname
    networkmanager = {
      enable = true; # Laptops do well with networkmanager
      #unmanaged = [ "virbr0" "lxdbr0" "lxdbr1" ];
    };
    useDHCP = false; # deprecated, should be false
    # Extra hostnames, hardcoded IP's are from Tailscale
    extraHosts = ''
      ${kubeMasterIP} ${kubeMasterHostname}
      100.95.25.107 shitbox
      192.168.122.107 rancher.lillecarl.com
    '';
  };
  # Enable systemd-resolved, takes care of splitting DNS across interfaces n stuff
  services.resolved.enable = true;

  # CUPS for printing documents.
  services.printing.enable = false;
  # Enable GlobalProtect VPN
  services.globalprotect.enable = true;
  # Enable Android debugging tools
  programs.adb.enable = true;

  # Fix local Kubernetes
  services.kubernetes = lib.mkIf kubeEnable {
    roles = [ "master" "node" ];
    masterAddress = kubeMasterHostname;
    apiserverAddress = "https://${kubeMasterHostname}:${toString kubeMasterAPIServerPort}";
    easyCerts = true;
    apiserver = {
      securePort = kubeMasterAPIServerPort;
      advertiseAddress = kubeMasterIP;
    };

    # use coredns
    addons.dns.enable = true;

    # needed if you use swap
    kubelet.extraOpts = "--fail-swap-on=false";
  };

  virtualisation = {
    libvirtd = {
      enable = true;
    };
    lxd = {
      enable = true;
      recommendedSysctlSettings = true;
    };
    lxc.lxcfs.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
    };
    waydroid.enable = true;
  };

  environment.systemPackages = with pkgs; [
    zoom-us # Yet another video conferencing tool
    jitsi-meet-electron # Video conferencing
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

  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  systemd = {
    network = {
      enable = false;
      #networks."vpn" = {
      #  enable = true;
      #  vrf = [ "vpnvrf" ];
      #};
      netdevs."vpn" = {
        enable = true;
        vrfConfig = {
          Table = 1337;
        };
        netdevConfig = {
          Kind = "vrf";
          Name = "vpn";
        };
      };
    };
    services.mdmonitor1 = {
      description = "Monitor RAID disks";
      wantedBy = [ "multi-user.target" ];
      script = "${pkgs.mdadm}/bin/mdadm --monitor -m root /dev/md1337";
    };

    # Disable the default NixOS mdadm monitor as it doesn't work at all
    services.mdmonitor.enable = false;

    # upower systemd service
    services.upower.enable = true;

    services.powerTune = {
      enable = true;
      path = with pkgs; [ powertop ];
      stopIfChanged = true;
      script = ''
        powertop --auto-tune || true
        echo "powersave" | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor || true
        ${pkgs.tpacpi-bat}/bin/tpacpi-bat -v -s SP 1 85 || true
      '';
    };

    timers.powerTune = {
      enable = true;
      wantedBy = [ "multi-user.target" ];
      timerConfig = {
        OnBootSec = "3m";
        OnUnitActiveSec = "3m";
        AccuracySec = "1m";
        Unit = "powerTune.service";
      };
    };

    # Clone everything from /sys-persist into /sys, no error handling
    #services.sysPersist = {
    #  enable = true;
    #  stopIfChanged = true;
    #  path = with pkgs; [ findutils gnused ];
    #  script = ''
    #    for file in $(find /sys-persist -type f)
    #    do
    #      cat $file > $(echo $file | sed "s/sys-persist/sys/")
    #    done
    #  '';
    #};

    #timers.sysPersist = {
    #  enable = true;
    #  wantedBy = [ "multi-user.target" ];
    #  timerConfig = {
    #    OnBootSec = "3m";
    #    OnUnitActiveSec = "3m";
    #    AccuracySec = "1m";
    #    Unit = "sysPersist.service";
    #  };
    #};

    sleep.extraConfig = ''
      #AllowSuspend=yes
      #AllowHibernation=yes
      #AllowSuspendThenHibernate=yes
      #AllowHybridSleep=yes
      #SuspendMode=
      #SuspendState=mem standby freeze
      #HibernateMode=platform shutdown
      #HibernateState=disk
      #HybridSleepMode=suspend platform shutdown
      #HybridSleepState=disk
      HibernateDelaySec=300min
    '';
  };

  #services.syncthing = {
  #  
  #};

  # Monitor laptop with Prometheus
  services.prometheus = lib.mkIf prometheusEnable {
    enable = true;
    globalConfig = {
      scrape_timeout = "10s";
      scrape_interval = "1m";
      evaluation_interval = "1m";
    };
    pushgateway = {
      enable = true;
    };
    scrapeConfigs = [
      {
        job_name = "prometheus";
        static_configs = [
          {
            targets = [ "127.0.0.1:9090" ];
          }
        ];
      }
      {
        job_name = "node";
        static_configs = [
          {
            targets = [ "127.0.0.1:9100" ];
          }
        ];
      }
      {
        job_name = "process";
        static_configs = [
          {
            targets = [ "127.0.0.1:9256" ];
          }
        ];
      }
      {
        job_name = "smartctl";
        static_configs = [
          {
            targets = [ "127.0.0.1:9633" ];
          }
        ];
      }
    ];
    exporters = {
      node = {
        enable = true;
        enabledCollectors = [
          "systemd"
          "processes"
        ];
      };
      process = {
        enable = true;
      };
      smartctl = {
        enable = true;
        devices = [ "/dev/nvme0n1" "/dev/nvme1n1" ];
      };
      #script = {
      #  enable = true;
      #  settings = {
      #    scripts = [
      #      {
      #        name = "fanspeed";
      #        script = ''
      #          
      #        '';
      #      }
      #    ];
      #  };
      #};
    };
  };

  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 446;
        domain = "localhost";
      };
    };
  };

  # enable emacs, running as a user daemon
  #services.emacs.enable = true;
  # Enable bluetooth
  services.blueman.enable = true;
  # Enables upower daemon
  services.upower.enable = true;
  # TODO configure this to relay messages out on the internet too
  services.postfix = {
    enable = true;
    setSendmail = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}
