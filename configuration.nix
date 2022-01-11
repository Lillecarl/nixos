# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

# discord curl -sI "https://discord.com/api/download?platform=linux&format=tar.gz" | grep -oP 'location: \K\S+'
let
  unstablegit = import /etc/nixos/unstable { config = config.nixpkgs.config; };
in
{
  nixpkgs.config.packageOverrides = pkgs: {
    #nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
    nur = import <nur> {
      inherit pkgs;
    };
  };
  imports = [
    <nixos-hardware/common/cpu/intel>
    <nixos-hardware/common/pc/ssd>
    <nixos-hardware/common/pc>
    # Import hardware configuration
    ./hardware-configuration.nix
    # Import boot configuration 
    ./boot.nix
  ];

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
    tailscale = {
      enable = true;
    };
    cron = {
      enable = true;
      #systemCronJobs = [
      #  "*/5 * * * * root . /etc/profile; cd /etc/nixos/nixpgs; git pull --all --force"
      #];
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
      #alsa.enable = true;
      #alsa.support32Bit = true;
      #jack.enable = true;
      pulse.enable = true;
      socketActivation = true;
    };
    #fail2ban = {
    #  enable = true;
    #  ignoreIP = [
    #    "192.168.0.0/16"
    #    "172.16.0.0/12"
    #    "10.0.0.0/8"
    #  ];
    #};
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
          "nixdev"
        ];
        shell = pkgs.zsh;
        createHome = true;
      };
    };
    groups = {
      nixdev = { };
    };
  };

  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    #gc = {
    #  automatic = true;
    #  dates = "03:00";
    #  options = "--delete-older-than 30d";
    #};
    # Automatically optimse store
    autoOptimiseStore = true;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true; # Required to load the broadcom drivers

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    notepadqq
    jq
    entr
    gitui
    #nixops
    element-desktop
    cmatrix sl cowsay fortune toilet oneko
    anydesk nix-index mpv xorg.xhost lm_sensors
    weechat curl emacs bind arping nix-prefetch nix-prefetch-github iperf3
    bash zsh powershell zoxide rustup
    wget git gitAndTools.git-imerge kdiff3 xclip freerdp alacritty wezterm
    vim neovim tmux zellij htop iotop iftop pciutils neofetch direnv
    wineWowPackages.full
    ncdu qemu_kvm dmidecode ksnip
    firefox brave tridactyl-native  torbrowser nyxt libsForQt5.kruler libsForQt5.yakuake
    gparted cmake tldr gitkraken lshw
    thunderbird evolution-data-server evolution-ews stow
    openvpn torsocks kgpg
    libsForQt5.networkmanager-qt bridge-utils
    vscode qtcreator units heroku
    libreoffice
    piper
    rofi
    rofimoji
    lazygit
    syncthing
    keychain
    thefuck
    oh-my-zsh
    nmap
    obs-studio gimp gwenview okular
    virt-manager OVMFFull numactl looking-glass-client barrier etcher
    ark archiver libarchive
    discord teamspeak_client qbittorrent lutris # teams
    bitwarden pwgen kwin-tiling
    spectre-meltdown-checker
    phoronix-test-suite geekbench sysbench stress-ng
    soldat-unstable unrar
    quickemu openssl

    nixpkgs-fmt

    pastebinit

    dbeaver dotnet-sdk_5 mono6 nodejs_latest yarn
    gnumake cmakeWithGui

    appimage-run # running appimages (shadow)
    nix-tree
    chezmoi
    kleopatra gpg-tui gnupg pinentry pinentry-qt pinentry-gtk2 pinentry-curses
    # Sound packages for pipewire
    kmix volctl

    # Infra management
    terraform ansible azure-cli

    # Hardware management
    smartmontools
    ddcutil # Monitor control

    #nur.repos.mweinelt.cmangos_tbc
    #nur.repos.nur-combined.stremio
  ];

  environment.etc = {
    "X11/xorg.conf.d/90-nvidia-i2c.conf" = {
      source = "${pkgs.ddcutil}/share/ddcutil/data/90-nvidia-i2c.conf";
    };
  };

  # Enable zsh                                                           
  programs.zsh.enable = true;                                           
                                                                        
  # Enable Oh-my-zsh                                                    
  programs.zsh.ohMyZsh = {                                              
    enable = true;                                                      
    plugins = [ "git" "sudo" "docker" "kubectl" ];                      
  };

  # Enable Microsoft corefonts
  fonts.fonts = with pkgs; [
    corefonts
    nerdfonts
  ];
  # Bash autocomplete with tab
  programs.bash.enableCompletion = true;
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  # Crypto stuff
  services.pcscd.enable = true;
  programs.gnupg.agent = {
     enable = true;
     pinentryFlavor = "gtk2";
     enableSSHSupport = true;
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
    #anbox = {
    #  enable = true;
    #};
  };
  #security.apparmor.enable = true;

  services.avahi = {       
    nssmdns = true;        
    enable = true;         
    ipv4 = true;           
    ipv6 = true;           
    publish = {            
      enable = true;       
      addresses = true;    
      workstation = true;  
    };                     
  };

  # Open ports in the firewall.
  #networking.firewall.allowedTCPPorts = [ 22 24800 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?
}

