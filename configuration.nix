# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  unstable = import <unstable> { config = config.nixpkgs.config; };
  custom = import /etc/nixos/nixpkgs { config = config.nixpkgs.config; };
in rec
{
  imports = [
    <nixos-hardware/system76> # Enable S76 unique stuff
    <nixos-hardware/common/pc/laptop> # Power stuff
    <nixos-hardware/common/pc/ssd> # FStrim, paging
    <nixos-hardware/common/cpu/intel> # Intel/i915 stuff (research more)
    ./hardware-configuration.nix
  ];

  #disabledModules = [ "hardware/video/displaylink.nix" ];

  nixpkgs = {
    # Allow proprietary software to be installed
    config.allowUnfree = true;
    #overlays = [
    #  (
    #    self: super: {
    #      virt-manager = super.virt-manager.override {
    #          buildInputs = with pkgs; [
    #            wrapGAppsHook
    #            libvirt-glib vte dconf gtk-vnc gnome.adwaita-icon-theme avahi
    #            gsettings-desktop-schemas libosinfo gtksourceview4
    #            gobject-introspection
    #            swtpm
    #          ];
    #      };
    #    }
    #  )
    #];
  };

  networking = {
    hostName = "lemur"; # System hostname
    networkmanager.enable = true; # Laptops do well with networkmanager
    useDHCP = false; # deprecated, should be false

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

  # Set your time zone.
  time.timeZone = "Europe/Stockholm";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
    # These settings makes Perl happy
    extraLocaleSettings = {
      LANGUAGE = "en_US.UTF-8";
      LC_ALL = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
    supportedLocales = [ "all" ];
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the Plasma 5 Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  services.xserver.videoDrivers = [
    "displaylink" # For the DELL docks at work
    "modesetting" # Standard driver
    "fbdev" # Enabled by default in NixOS
  ];
  #services.xserver.videoDrivers = [ "modesetting" "fbdev" ];

  # Configure keymap in X11
  services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  programs.adb.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.lillecarl = {
    uid = 1000;
    shell = pkgs.zsh;
    isNormalUser = true;
    extraGroups = [
      "wheel" # enables sudo
      "libvirtd" # allow use of libvirt without sudo
      "networkmanager" # allow editing network connections without sudo
      "lxd" # allow userspace container management without sudo
      "flatpak" # allow managing flatpak
      "adbusers" # allow usage of adb
    ];
  };

  virtualisation = {
    libvirtd = {
      enable = true;
    };
    lxd = {
      enable = true;
      recommendedSysctlSettings = true;
    };
    #virtualbox = {
    #  host = {
    #    enable = true;
    #    enableExtensionPack = true;
    #  };
    #};
    #anbox = {
    #  enable = true;
    #};
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # Chat apps
    teams # Microsoft Teams collaboration suite (Electron)
    slack # Team collaboration chat (Electron)
    discord # Gaming chat application
    zoom # Meetings application
    # Media apps
    vlc # Media Player
    ytmdesktop # YouTube Music Player
    # Commandline tools
    cmatrix # Just scrolling to look really cool
    system76-firmware # System76 firmware tools
    mailutils # Sending mail from commandline 
    vim # Modal CLI text editor
    neovim # Modal CLI text editor, modern version of Vim
    amp # Modal CLI text editor, modern, rust
    emacs # well, it's emacs...
    fd # not sure, doom-emacs recommends it
    ripgrep # Modern rusty grep
    lsof # Check who uses file
    wget # Fetch things quicly with HTTP
    gnufdisk # CLI partition management
    curl # All things HTTP and other web transfer protocols
    tmux # terminal multiplexer
    zellij # discoverable terminal multiplexer written in rust
    htop # NCurses "task manager"
    powertop # See power information
    iotop # See disk IO information
    nix-tree # visualize the Nix store interactively
    nix-update # Tool to help updating nix packages
    nix-prefetch-github # fetch nix package from github
    niv # Dependency manager for Nix, which is a dependency manager (wat)
    vulnix # Nix vulnerability scanner
    gitFull
    tig
    git-imerge # interactive and incremental git merging utility
    git-trim
    git-cola
    git-fire # Save your code, then your life
    alacritty # Fast crossplatform terminal emulator
    xclip # | "xclip -sel clip" is what you want
    ansible # Server automation tool
    iftop # Show interface throughput and which IP's
    smartmontools # Read SSD SMART information
    glances # Fancy system monitoring TUI
    lm_sensors # Read sensors
    file # Show information about files
    jq # CLI JSON utility, piping JSON here will always pretty-print it
    desktop-file-utils # Required for VS Code live share
    powershell # Microsofts shell implementation
    ncdu # NCurses Disk Utility (TUI way of finding big files and folders)
    scrot # Commandline print-screen tool, use with GnuPG for automatic screenshotting
    pulseaudio # For pactl
    dmidecode # system information
    pciutils # PCI(e) utilities (lspci for example)
    usbutils # USB utils
    xdotool # Tools to automate mouse and keyboard in X
    wtype # Wayland version of xdotools
    libsForQt5.qt5.qttools # qdbus command comes from here
    tree # Show things as a CLI tree in folders
    neofetch # Tool for fancy print-screens
    bwm_ng # Check current network throughput by reading interface values
    killall # Kill processes by name
    swtpm # needed to emulate TPM on QEMU
    gnupg # PGP implementation
    ranger # file manager
    fzf # fuzzy finder, pipe to this for nice search
    unipicker # unicode char finder
    bitwarden-cli # Password manager CLI
    thefuck # Command that corrects your previous command
    speedtest-cli # Speedtest from the commandline
    poppler_utils # Utilities for PDF rendering
    imagemagick # CLI for doing image stuff
    xbindkeys # Binding keys for X
    xorg.xev # Monitor Keypresses, useful when troubleshooting keylayouts
    conntrack_tools # Connection tracking userspace tools
    iptstate # Conntrack "top like" tool
    nixos-generators # Tools for generating nixos images (AWS, Azure, ISO etc..)
    archiver # "Generic" decompression tool
    unzip # Decompress zip files
    unrar # Decompress rar files
    libressl # Crypto library, userspace tools
    libsecret # Library for storing secrets securely in userspace
    fsql # Query the filesystem with SQL
    pstree # Show process tree as a tree
    gist # Tool to post files to gist.github.com straight away
    # Programming tools
    vscode # Programming editor, growing into an IDE
    kdiff3 # Well know diffing tool
    kompare # KDE diffing tool
    python3 # Language interpreter
    python39Packages.boto3 # AWS Python library
    nodejs # Javascript with OS access
    gnumake # GNU make
    clang # Cool modular C/C++ compiler
    gcc # Old but gold C/C++ and others compiler
    falkon # Qt web browser
    # System tools
    ark # Archiving tool
    gparted # GUI partition manager
    virt-manager # Virtualisation manager
    virt-manager-qt # Shitty version of virt-manager
    wireshark # Defactor network traffic sniffing tool
    ksystemlog # KDE syslog viewer
    etcher # Balena Etcher, GUI for dd (flash SD cards)
    nix-bash-completions # Nix completions in bash, probably ZSH compatible
    hardinfo # Hardware information
    # Productivity tools
    thunderbird # Mail client
    claws-mail # Mail client
    evolution # Mail client
    mailspring # Mail client
    libreoffice # MS office compatible productivity suite
    obs-studio # Screen recording/streaming utility
    freerdp # Remote Desktop Protocol client
    kgpg # KDE pgp tool
    copyq # Clipboard manager
    kate # KDE text editor
    notepadqq # Notepad++ "clone" for Linux
    geany # Supposed to be like Notepad++
    ghostwriter # Markdown editor
    teamviewer # Remote Desktop Solution
    #electronim # This isn't yet packaged for NixOS, but put it here as a reminder of the future
    #latte-dock # Alternative KDE dock (Mac style)
    qbittorrent # OpenSource Qt Bittorrent client
    okular # PDF viewer
    # Misc
    unstable.scrcpy
    wineWowPackages.full
    libsForQt5.kdeconnect-kde # Integrate your DE with things
    libsForQt5.plasma-browser-integration # Integrate KDE with 
    libsForQt5.kcalc # KDE calculator
    krita # KDE alternative to GIMP
    gimp # Photoshop alternative
    kdenlive # KDE alternative to Windows Movie Maker
    webcamoid # Webcam application
    # Unstable tools, grouped in case we don't have access to the channels,
    # (while reinstalling) we can just comment them all out with a visual block.
    unstable.youtube-dl # Download media from a lot of different websites
    unstable.zellij # discoverable terminal multiplexer written in rust
    unstable.wezterm # Crossplatform terminal emulator, supports ligatures
    unstable.rofi # Searchable window title window switcher
    unstable.rofimoji # Emoji/Char picker for rofi
    unstable.ungoogled-chromium # Chromium without Google
    unstable.bitwarden # Password manger
    unstable.dotnet-sdk_6 # Latest dotnet
    unstable.go # Golang
    unstable.gitkraken # Git GUI
    unstable.azure-cli # Azure CLI tooling
    unstable.awscli # AWS CLI tooling
    unstable.brave # Web brower, Chromium based
    unstable.nyxt # Hackable "power-browser"
    unstable.qutebrowser # Keyboard driven browser, Python and PyQt based
    unstable.terraform # Cloud orchestrator
    unstable.dbeaver # SQL database GUI
    #unstable.displaylink # Driver for DisplayLink docks, works like shit
    #unstable.anbox # look into what's blocking anbox from running a late kernel
  ];

  environment.variables = 
  {
    EDITOR = "vim";
    VISUAL = "vim";
    ARM_THREEPOINTZERO_BETA_RESOURCES = "true";
  };

  #environment.etc."X11/xorg.conf.d/20-evdi.conf" = {
  #  enable = true;
  #  text = ''
  #    Section "OutputClass"
  #    	Identifier "DisplayLink"
  #    	MatchDriver "evdi"
  #    	Driver "modesetting"
  #    	Option "AccelMethod" "none"
  #    EndSection
  #  '';
  #};

  # Enable zsh
  programs.zsh.enable = true;

  # Enable Oh-my-zsh
  programs.zsh.ohMyZsh = {
    enable = true;
    plugins = [ "git" "sudo" "docker" "kubectl" ];
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
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

    # This breaks the mdmonitor service nixos installs by appending bogus to the end
    # the effect is that we don't have this unit as failed in systemctl --failed
    services.mdmonitor = {
      description = "Monitor RAID disks";
      wantedBy = [ "multi-user.target" ];
      script = "${pkgs.mdadm}/bin/mdadm --monitor -m root /dev/md1337";
    };

    # This service works be executing before sleeping stays running while
    # the sleep target is active, and kills itself when sleep target dies.
    # This works with the combination of:
    #   before sleep.target
    #   unitConfig.StopWhenUnneeded
    #   serviceConfig.Type
    #   serviceConfig.RemainAfterExit
    # 
    # It also runs as my user (lillecarl, uid 1000)
    # XDG_RUNTIME_DIR must be set for systemctl to work, see https://serverfault.com/a/937012
    services.HibernatePipeWireState = {
      before = [ "sleep.target" ];
      wantedBy = [ "sleep.target" ];
      description = "Start pipewire after hibernation";
      stopIfChanged = true;
      unitConfig = {
        StopWhenUnneeded = "yes";
      };
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = "yes";
        User = "1000";
      };

      # ExecStop =
      preStop = ''
        echo "Starting pipewire services"
        # Required to get systemctl --user working
        export XDG_RUNTIME_DIR=/run/user/$(id -u)
        # For some reason this starts pipewire up properly
        systemctl --user stop pipewire-pulse || true
      '';

      # ExecStart =
      script = ''
        echo "Stopping pipewire services"
        # Required to get systemctl --user working
        export XDG_RUNTIME_DIR=/run/user/$(id -u)
        # Stop pipewire daemon
        systemctl --user stop pipewire || true
      '';
    };
    #sleep.extraConfig = '' 
    #  HibernateDelaySec=1h
    #  #AllowSuspend=no
    #  #AllowSuspendThenHibernate=yes
    #  #AllowHibernate=yes
    #  #AllowHybridSleep=no
    #'';
  };

  # rtkit for pipewire? (Recommended on NixOS wiki)
  security.rtkit.enable = true;
  # Remove reboot commands from history for user lillecarl to prevent accidental reboots
  services.cron = {
    enable = true;
    systemCronJobs = [
      "* * * * * lillecarl sed -i \"/.*sudo systemctl reboot.*/d\" /home/lillecarl/.zsh_history"
    ];
  };

  # Enable Flatpak
  services.flatpak.enable = true;
  # xdg desktop intergration (required for flatpak)
  xdg.portal = {
    enable = true;
    gtkUsePortal = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
  # Adding gnome-keyring, seems like KDE wallet isn't supported with mailspring?
  services.gnome.gnome-keyring.enable = true;
  #programs.seahorse.enable = true;
  # Enables upower daemon
  services.upower.enable = true;
  # Enabled fwupd daemon, allows applications to update firmware
  services.fwupd.enable = true;
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
    pulse.enable = true;
    socketActivation = true;
  };

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

