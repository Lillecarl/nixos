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
    ../common
  ];

  nix.autoOptimiseStore = true;

  nixpkgs = {
    # Allow proprietary software to be installed
    config.allowUnfree = true;
  };

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  networking = {
    hostName = "lemur"; # System hostname
    networkmanager.enable = true; # Laptops do well with networkmanager
    useDHCP = false; # deprecated, should be false
    # Extra hostnames, hardcoded IP's are from Tailscale
    extraHosts = ''
      ${kubeMasterIP} ${kubeMasterHostname}
      100.95.25.107 shitbox
      100.120.205.93 lemur
    '';

    #wireguard = {
    #  enable = true;
    #  interfaces."ovpn" = {
    #    privateKey = "gLwT/gGP+oG1MTGBciRpxVPqceDyXGtXJkOzHAYAFXI=";
    #    ips = [ "172.25.172.124/32" "fd00:0000:1337:cafe:1111:1111:9562:0542/128" ];
    #    table = "1337";
    #    peers = [
    #      {
    #        publicKey = "UPKLcNO8+oav7Bsc8afNeN482pnieYLOBAh4vXdWFT0=";
    #        allowedIPs = [ "0.0.0.0/0" "::/0" ];
    #        endpoint = "vpn12.prd.kista.ovpn.com:9929";
    #        persistentKeepalive = 25;
    #      }
    #    ];
    #  };
    #};

    # Open ports in the firewall.
    #networking.firewall.allowedTCPPorts = [ ... ];
    #networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    #networking.firewall.enable = false;
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
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
    podman = {
      enable = true;
      dockerCompat = true;
    };
    waydroid.enable = true;
  };

  environment.systemPackages = with pkgs; [
    # Kernel modules with userspace commands
    config.boot.kernelPackages.cpupower
    config.boot.kernelPackages.turbostat
    config.boot.kernelPackages.system76
    config.boot.kernelPackages.system76-io
    config.boot.kernelPackages.system76-acpi
    config.boot.kernelPackages.usbip
  ];

  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  systemd = {
    network = {
      enable = true;
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
    services.sysPersist = {
      enable = true;
      stopIfChanged = true;
      path = with pkgs; [ findutils gnused ];
      script = ''
        for file in $(find /sys-persist -type f)
        do
          cat $file > $(echo $file | sed "s/sys-persist/sys/")
        done
      '';
    };

    timers.sysPersist = {
      enable = true;
      wantedBy = [ "multi-user.target" ];
      timerConfig = {
        OnBootSec = "3m";
        OnUnitActiveSec = "3m";
        AccuracySec = "1m";
        Unit = "sysPersist.service";
      };
    };

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
    addr = "127.0.0.1";
    port = 446;
    domain = "localhost";
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
  system.stateVersion = "21.05"; # Did you read the comment?
}

