# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let
  unstable = import <unstable> { config = config.nixpkgs.config; };
  #master = import <master> { config = config.nixpkgs.config; };
  custom = import /etc/nixos/nixpkgs { config = config.nixpkgs.config; };

  kubeEnable = false;
  kubeMasterIP = "192.168.122.1";
  kubeMasterHostname = "api.kube";
  kubeMasterAPIServerPort = 6443;

  prometheusEnable = true;
in
rec
{
  imports = [
    <nixos-hardware/system76> # Enable S76 unique stuff
    <nixos-hardware/common/pc/laptop> # Power stuff
    <nixos-hardware/common/pc/ssd> # FStrim, paging
    <nixos-hardware/common/cpu/intel> # Intel/i915 stuff (research more)
    ./hardware-configuration.nix
    ./cachix.nix
  ];

  nix.autoOptimiseStore = true;

  nixpkgs = {
    # Allow proprietary software to be installed
    config.allowUnfree = true;
  };

  networking = {
    hostName = "lemur"; # System hostname
    networkmanager.enable = true; # Laptops do well with networkmanager
    useDHCP = false; # deprecated, should be false
    extraHosts = "${kubeMasterIP} ${kubeMasterHostname}";

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
    font = "Hack";
    keyMap = "us";
  };

  # Enable xwayland, not everything is wayland yet.
  programs.xwayland.enable = true;
  # Enable the X11 windowing system.
  services.xserver.enable = true;
  # Enable the Plasma 5 Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;
  # Configure keymap in X11
  services.xserver.layout = "us";
  # Available videodrivers
  #services.xserver.videoDrivers = [
  #  #"displaylink" # For the DELL docks at work
  #  "modesetting" # Standard driver
  #  "fbdev" # Enabled by default in NixOS
  #];
  services.xserver.displayManager.setupCommands = ''
    ${pkgs.xorg.xhost}/bin/xhost +local:
  '';


  # Enable CUPS to print documents.
  # services.printing.enable = true;


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

  # Allow root to map to LilleCarl user in LXD container
  users.users.root = {
    subUidRanges = [
      {
        count = 1;
        startUid = users.users.lillecarl.uid;
      }
    ];
    subGidRanges = [
      {
        count = 1;
        startGid = 1000;
      }
    ];
  };

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
      "podman" # allow usage of adb
      "wireshark" # allow wireshark dumpcap
    ];
  };

  virtualisation = {
    libvirtd = {
      enable = true;
    };
    lxd = {
      enable = true;
      package = unstable.lxd;
      recommendedSysctlSettings = true;
    };
    podman = {
      enable = true;
      dockerCompat = true;
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # Chat apps
    unstable.teams # Microsoft Teams collaboration suite (Electron)
    unstable.slack # Team collaboration chat (Electron)
    unstable.discord # Gaming chat application
    signal-desktop # Secure messenger
    unstable.zoom # Meetings application
    # Media apps
    vlc # Media Player
    mpv # Media Player
    celluloid #  MPV GTK frontend wrapper
    ytmdesktop # YouTube Music Player
    # Commandline tools
    unstable.tldr # Like, TL;DR manpages
    unstable.go # Golang
    unstable.dotnet-sdk_6 # Latest dotnet
    unstable.azure-cli # Azure CLI tooling
    unstable.awscli # AWS CLI tooling
    unstable.aws-nuke # Nuke AWS account completely
    unstable.terraform # Cloud orchestrator
    unstable.terragrunt # Terraform Wrapper that does nice things
    unstable.terraform-lsp # Terraform Language Server
    unstable.youtube-dl # Download media from a lot of different websites
    unstable.zellij # discoverable terminal multiplexer written in rust
    zoxide # Rust implementation of z/autojump
    age # Modern crypto (kinda like PGP it seems)
    chezmoi # dotfile manager
    pmutils # Suspend tools
    inotify-tools # CLI tools for inotify in Linux
    sshfs # Mount SFTP as filesystem
    rclone # rsync for clouds (+ loads of other cool things)
    kompose # Kubernetes docker-compose like tool
    kubectl # Kubernetes management cli
    kubernetes # Kubernetes packages
    bind # brings the dig command
    xortool # xor key bruteforcing tool
    wireshark-cli # Wireshark CLI
    termshark # Wireshark TUI?
    entr # Run commands when files change
    cmatrix # Just scrolling to look really cool
    system76-firmware # System76 firmware tools
    mailutils # Sending mail from commandline 
    libnotify # Cli utils for sending KDE notifications
    vim # Modal CLI text editor
    neovim # Modal CLI text editor, modern version of Vim
    amp # Modal CLI text editor, modern, rust
    kakoune # Modal editor, faster because of fewer keystrokes
    emacs # well, it's emacs...
    fd # not sure, doom-emacs recommends it
    ripgrep # Modern rusty grep
    lsof # Check who uses file
    ripgrep # Rust grep implmenetation, not POSIX compliant
    wget # Fetch things quicly with HTTP
    gnufdisk # CLI partition management
    efitools # Tools for managing EFI, variables and such
    curl # All things HTTP and other web transfer protocols
    tmux # terminal multiplexer
    htop # NCurses "task manager"
    unstable.bottom # Task Manager written in Rust
    powertop # See power information
    iotop # See disk IO information
    nixpkgs-fmt # Format Nix like the Nix project wants
    nix-top # See what nix is doing when it's doing things
    nix-tree # visualize the Nix store interactively
    nix-update # Tool to help updating nix packages
    nix-direnv # Nix direnv implementation
    nix-prefetch-github # fetch nix package from github
    niv # Dependency manager for Nix, which is a dependency manager (wat)
    lorri # nix-shell alternative
    direnv # Do environment things based on cd
    cachix # Nix binary cache
    vulnix # Nix vulnerability scanner
    gitFull
    unstable.lazygit # Git TUI, golang
    unstable.gitui # Git TUI, rust
    overcommit # Git hooks manager
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
    yq # CLI YAML utility, useful for those that thing YAML is a bit shit
    desktop-file-utils # Required for VS Code live share
    powershell # Microsofts shell implementation
    ncdu # NCurses Disk Utility (TUI way of finding big files and folders)
    scrot # Commandline print-screen tool, use with GnuPG for automatic screenshotting
    maim # Commandline print-screen tool, use with GnuPG for automatic screenshotting
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
    nnn # file manager
    fzf # fuzzy finder, pipe to this for nice search
    unipicker # unicode char finder
    unstable.bitwarden-cli # Password manager CLI
    thefuck # Command that corrects your previous command
    speedtest-cli # Speedtest from the commandline
    poppler_utils # Utilities for PDF rendering
    imagemagick # CLI for doing image stuff
    xbindkeys # Binding keys for X
    xorg.xev # Monitor Keypresses, useful when troubleshooting keylayouts
    xorg.xhost # Not sure, used for X11 socket forwarding
    xorg.xinit # Well starting x?
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
    unstable.vscode # Programming editor, growing into an IDE
    kdiff3 # Well know diffing tool
    ruby # Ruby programming language
    python3 # Language interpreter
    python39Packages.boto3 # AWS Python library
    nodejs # Javascript with OS access
    gnumake # GNU make
    clang # Cool modular C/C++ compiler
    gcc # Old but gold C/C++ and others compiler
    adoptopenjdk-jre-bin # Java runtime
    # System tools
    ark # Archiving tool
    gparted # GUI partition manager
    virt-manager # Virtualisation manager
    virt-manager-qt # Shitty version of virt-manager
    wireshark # Defactor network traffic sniffing tool
    ksystemlog # KDE syslog viewer
    etcher # Balena Etcher, GUI for dd (flash SD cards)
    nix-bash-completions # Nix completions in bash
    nix-zsh-completions # Nix completions in ZSH
    bash-completion # Bash cli autocomplete
    hardinfo # Hardware information
    # Productivity tools
    unstable.dbeaver # SQL database GUI
    unstable.wezterm # Crossplatform terminal emulator, supports ligatures
    unstable.bitwarden # Password manger
    unstable.rofi # Searchable window title window switcher
    unstable.rofimoji # Emoji/Char picker for rofi
    thunderbird # Mail client
    unstable.gitkraken # Git GUI
    claws-mail # Mail client
    evolution # Mail client
    mailspring # Mail client
    mucommander # file manager, written in Java
    libreoffice # MS office compatible productivity suite
    unstable.obs-studio # Screen recording/streaming utility
    freerdp # Remote Desktop Protocol client
    kgpg # KDE pgp tool
    copyq # Clipboard manager
    kate # KDE text editor
    notepadqq # Notepad++ "clone" for Linux
    geany # Supposed to be like Notepad++
    ghostwriter # Markdown editor
    unstable.teamviewer # Remote Desktop Solution
    audacity # Audio software
    qtractor # Audio software
    #electronim # This isn't yet packaged for NixOS, but put it here as a reminder of the future
    qbittorrent # OpenSource Qt Bittorrent client
    okular # PDF viewer
    unstable.ytmdesktop # Youtube Music player
    # Misc
    unstable.scrcpy
    wineWowPackages.full
    krita # KDE alternative to GIMP
    gimp # Photoshop alternative
    kdenlive # KDE alternative to Windows Movie Maker
    webcamoid # Webcam application
    # Web browsers
    unstable.brave # Web brower, Chromium based
    unstable.ungoogled-chromium # Chromium without Google
    unstable.nyxt # Hackable "power-browser"
    unstable.qutebrowser # Keyboard driven browser, Python and PyQt based
    # Fonts
    corefonts
    helvetica-neue-lt-std
    xkcd-font
    hack-font
    fira-code
    jetbrains-mono
    # Kernel modules with userspace commands
    config.boot.kernelPackages.cpupower
    config.boot.kernelPackages.turbostat
    config.boot.kernelPackages.system76
    config.boot.kernelPackages.system76-io
    config.boot.kernelPackages.system76-acpi
  ];

  environment.variables =
    {
      EDITOR = "nvim";
      VISUAL = "nvim";
      ARM_THREEPOINTZERO_BETA_RESOURCES = "true";
    };

  # Enable noisetorch, noise suppression for microphones using pulse/pipewire
  programs.noisetorch.enable = true;
  # Enable wireshark
  programs.wireshark.enable = true;
  # gnupg settings
  programs.gnupg.agent = {
    enable = true;
    pinentryFlavor = "qt";
  };
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
      AllowSuspend=yes
      AllowHibernation=yes
      AllowSuspendThenHibernate=yes
      AllowHybridSleep=yes
      SuspendMode=suspend
      SuspendState=mem standby freeze
      #HibernateMode=platform shutdown
      HibernateMode=suspend
      HibernateState=disk
      HybridSleepMode=suspend platform shutdown
      HybridSleepState=disk
      HibernateDelaySec=180min
    '';
  };

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

  security.pam.loginLimits = [
    { # This fixes "ip vrf exec" for reasons still "unknown" (haven't read up on yet)
      domain = "*"; 
      item = "memlock"; # Locked memory, required for BPF programs
      type = "-"; # This is instead of hard/soft?
      value = 16384; # Value mentioned on RedHat bugzilla
    }
  ];

  security.sudo = {
    enable = true;
    # Allow some commands superuser rights without password
    extraRules = [
      {
        users = [ "lillecarl" ];
        commands = [
          {
            command = "${pkgs.htop}/bin/htop --readonly";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };

  # enable tailscale daemon
  #services.tailscale.enable = true;
  #services.tailscale.package = unstable.pkgs.tailscale;

  # enable emacs, running as a user daemon
  services.emacs.enable = true;

  services.blueman.enable = true;
  # rtkit for pipewire? (Recommended on NixOS wiki)
  security.rtkit.enable = true;
  # Enable Flatpak
  services.flatpak.enable = true;
  # xdg desktop intergration (required for flatpak)
  xdg.portal = {
    enable = true;
    gtkUsePortal = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
  # Enables upower daemon
  services.upower.enable = true;
  # Enabled fwupd daemon, allows applications to update firmware
  services.fwupd.enable = true;
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  # Enable PipeWire A/V daemon
  # replaces all other sound daemons
  services.pipewire = {
    enable = true;
    alsa.enable = true; # Required by: Audacity
    #alsa.support32Bit = true; # Probably never required on NixOS
    jack.enable = true; # Required by: Qtractor
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
