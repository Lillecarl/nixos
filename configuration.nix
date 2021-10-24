# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

# discord curl -sI "https://discord.com/api/download?platform=linux&format=tar.gz" | grep -oP 'location: \K\S+'
let
  unstablegit = import /etc/nixos/unstable { config.allowUnfree = true; };
in
{
  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };
  imports = [
    # Import hardware configuration
    ./hardware-configuration.nix
    # Import boot configuration 
    ./boot.nix
  ];

  # Networking, virbr0 is WAN iface
  networking = {
    hostName = "shitbox";
    hostId = "43211234";
    useNetworkd = true;
    useDHCP = false;
    nameservers = [ "1.1.1.1" ];
    bridges.virbr0.interfaces = [ "eno1" ];
    interfaces.eno1.useDHCP = false;
    interfaces.virbr0.useDHCP = true;
  };

  # Set your time zone.
  time.timeZone = "Europe/Stockholm";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
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
    cron = {
      enable = true;
      #systemCronJobs = [
      #  "*/5 * * * * root . /etc/profile; cd /etc/nixos/nixpgs; git pull --all --force"
      #];
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
    # Disable CUPS printing
    printing = {
      enable = false;
    };
    # Enable SSD trimming
    fstrim = {
      enable = true;
    };
    # Run sound through pipewire
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      jack.enable = true;
      pulse.enable = true;
      socketActivation = true;
    };
    fail2ban = {
      enable = true;
      ignoreIP = [
        "192.168.0.0/16"
        "172.16.0.0/12"
        "10.0.0.0/8"
      ];
    };
    openssh = {
      enable = true;
      forwardX11 = true;
      logLevel = "VERBOSE";
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
    flatpak = {
      enable = true;
    };
  };

  # xdg desktop intergration (required for flatpak)
  xdg.portal = {
    enable = true;
    gtkUsePortal = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    defaultUserShell = pkgs.zsh;
    users = {
      lillecarl = {
        uid = 1000;
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "networkmanager"
          "libvirt"
          "lxd"
          "flatpak"
          "kvm"
        ];
        shell = pkgs.zsh;
        createHome = true;
      };
    };
  };

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    gc = {
      automatic = true;
      dates = "03:00";
      options = "--delete-older-than 30d";

#      extraOptions = ''
#        min-free = ${toString (10 * 1024 * 1024 * 1024)}
#        max-free = ${toString (20 * 1024 * 1024 * 1024)}
#      '';
    };
    # Automatically optimse store
    autoOptimiseStore = true;
 };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true; # Required to load the broadcom drivers

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    cmatrix sl cowsay fortune toilet oneko
    anydesk nix-index mpv xorg.xhost
    weechat curl emacs bind arping nix-prefetch nix-prefetch-github iperf3
    bash zsh powershell zoxide rustup
    wget git gitAndTools.git-imerge kdiff3 xclip freerdp alacritty
    vim neovim tmux htop iotop iftop pciutils neofetch direnv
    wineWowPackages.full
    ncdu qemu_kvm dmidecode
    firefox brave tridactyl-native  torbrowser nyxt libsForQt5.kruler #ungoogled-chromium
    gparted cmake tldr gitkraken lshw
    thunderbird evolution-data-server evolution-ews stow
    openvpn torsocks kgpg
    libsForQt5.networkmanager-qt bridge-utils
    vscode qtcreator units heroku
    libreoffice
    obs-studio gimp gwenview okular
    virt-manager OVMF numactl looking-glass-client barrier etcher
    ark archiver libarchive
    teams discord teamspeak_client qbittorrent lutris
    bitwarden pwgen kwin-tiling
    spectre-meltdown-checker
    phoronix-test-suite geekbench sysbench stress-ng
    soldat-unstable

    pastebinit
    python27Full
    python37Full

    dbeaver dotnet-sdk_5 mono6 nodejs_latest yarn
    gnumake cmakeWithGui

    appimage-run # running appimages (shadow)
    nix-tree

    # Sound packages for pipewire
    kmix pasystray volctl

    # Infra management
    terraform-full ansible

    # Hardware management
    smartmontools

    #nur.repos.mweinelt.cmangos_tbc
    #nur.repos.nur-combined.stremio
  ];

  # Enable Microsoft corefonts
  fonts.fonts = [ pkgs.corefonts ];
  # Bash autocomplete with tab
  programs.bash.enableCompletion = true;
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.

  #system.autoUpgrade = {
  #  enable = true;
  #  allowReboot = true;
  #  dates = "05:00";
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
  security.apparmor.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 24800 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?
}

