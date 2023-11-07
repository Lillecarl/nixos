{ pkgs, inputs, ... }: {
  security.pam.services.login.enableGnomeKeyring = true;
  security.pam.services.greetd.enableGnomeKeyring = true;
  security.pam.services.swaylock.enableGnomeKeyring = true;

  #services.envfs = {
  #  enable = true;
  #  #extraFallbackPathCommands = ''
  #  #  ln -s ${pkgs.coreutils}/bin/env $out/env
  #  #'';
  #};
  #programs.nix-ld.enable = true;

  programs.firefox = {
    enable = true;
    nativeMessagingHosts.tridactyl = true;
    nativeMessagingHosts.ff2mpv = true;
    nativeMessagingHosts.fxCast = true;
  };

  environment.enableDebugInfo = true;

  hardware.uinput.enable = true;
  boot.tmp.useTmpfs = true;

  # Select internationalisation properties.
  i18n = rec {
    defaultLocale = "en_DK.UTF-8";
    extraLocaleSettings = {
      LANG = defaultLocale;
      LC_ALL = defaultLocale;
      LC_TELEPHONE = "sv_SE.UTF-8";
    };
    supportedLocales = [ "all" ];
  };

  programs.dconf.enable = true;

  # Disable network-manager wait-online service that prohibits nixos-rebuild
  systemd.services.NetworkManager-wait-online.enable = false;

  # Use us keymap
  console = {
    keyMap = "us";
  };

  environment.systemPackages = with pkgs; [
    # Commandline tools (CLI)
    virtiofsd # VirtIO filesystem daemon
    home-manager # Tool to build your home environment in a reproducible fashion, anywhere with Nix!
    rmtrash # rm compatible remove tool
    inetutils # Common internet utilities
    nmap # Network scanner
    execline # Tools for dbus n stuff
    handlr # xdg-open alternative
    cookiecutter # Simple project template engine
    distrobuilder # Build other distros
    asciinema # Terminal session recorder
    mongodb-tools # MongoDB tools like dumping etc.
    starship # Shell prompt
    bat # Cat clone with syntax highlight and git integration
    tealdeer # Like, TL;DR manpages
    wireguard-tools # Wireguard tools
    aws-nuke # Nuke AWS account completely
    age # Modern crypto written in Go
    rage # Modern crypto written in Rust (Compatible with Age)
    chezmoi # dotfile manager
    pmutils # Suspend tools
    inotify-tools # CLI tools for inotify in Linux
    sshfs # Mount SFTP as filesystem
    rclone # rsync for clouds (+ loads of other cool things)
    gnumake # Make for packer for rhel template
    sipcalc # Subnet calculator
    buildah # Build OCI images
    bind # brings the dig command
    dogdns # dig without poop
    whois # whois command
    (lowPrio wireshark-cli) # Wireshark CLI
    (lowPrio termshark) # Wireshark TUI?
    entr # Run commands when files change
    pv # Monitor pipe progress
    libnotify # Cli utils for sending KDE notifications
    vim # Modal CLI text editor
    neovim # Modal CLI text editor, modern version of Vim
    amp # Modal CLI text editor, modern, rust
    helix #  Modern modal editor, written in Rust
    ripgrep # Modern rusty grep
    lsof # Check who uses file
    ripgrep # Rust grep implmenetation, not POSIX compliant
    wget # Fetch things quicly with HTTP
    gnufdisk # CLI partition management (MBR)
    gptfdisk # CLI partition management (GPT)
    efitools # Tools for managing EFI, variables and such
    curl # All things HTTP and other web transfer protocols
    tmux # terminal multiplexer
    htop # NCurses "task manager"
    bottom # Task Manager written in Rust
    powertop # See power information
    iotop # See disk IO information
    nixpkgs-fmt # Format Nix like the Nix project wants
    manix # Nix documentation search tool
    nix-du # Nix disk usage check
    nix-index # Files database for nixpkgs (find uninstalled commands)
    nix-top # See what nix is doing when it's doing things
    nix-tree # visualize the Nix store interactively
    nix-update # Tool to help updating nix packages
    nix-prefetch # nix prefetcher
    nix-prefetch-github # fetch nix package from github
    comma # Run stuff without installing it
    lorri # nix-shell alternative
    pijul # Patch based git alternative (Similiar to darcs but written in rust)
    gitFull # Git and all beloning standard packages
    lazygit # Git TUI, golang
    gitui # Git TUI, rust
    overcommit # Git hooks manager
    github-cli # CLI for github interactions
    git-open # Open repo with browser in $sourcecontrol website
    git-imerge # interactive and incremental git merging utility
    bfg-repo-cleaner # Clean repos that are huge
    wl-clipboard # Wayland clipboard manipulation
    ansible # Server automation tool
    iftop # Show interface throughput and which IP's
    smartmontools # Read SSD SMART information
    glances # Fancy system monitoring TUI
    lm_sensors # Read sensors
    file # Show information about files
    jq # CLI JSON utility, piping JSON here will always pretty-print it
    yq # CLI YAML utility, useful for those that thing YAML is a bit shit
    gron # Flatten JSON to make it easy to grep
    desktop-file-utils # Required for VS Code live share
    ncdu # NCurses Disk Utility (TUI way of finding big files and folders)
    scrot # Commandline print-screen tool, use with GnuPG for automatic screenshotting
    pulseaudio # For pactl
    dmidecode # system information
    pciutils # PCI(e) utilities (lspci for example)
    usbutils # USB utils
    bridge-utils # Bridge utils
    xdotool # Tools to automate mouse and keyboard in X
    wtype # Wayland version of xdotools
    libsForQt5.qt5.qttools # qdbus command comes from here
    tree # Show things as a CLI tree in folders
    neofetch # Tool for fancy print-screens
    bwm_ng # Check current network throughput by reading interface values
    killall # Kill processes by name
    swtpm # needed to emulate TPM on QEMU
    gnupg # PGP implementation
    keychain-wrapper # Easier key management
    ranger # file manager
    nnn # file manager
    fzf # fuzzy finder, pipe to this for nice search
    unipicker # unicode char finder
    bitwarden-cli # Password manager CLI
    thefuck # Command that corrects your previous command
    speedtest-cli # Speedtest from the commandline
    imagemagick # CLI for doing image stuff
    waypipe # Wayland forwarding (Like X11 forwarding, but for Wayland)
    libinput # Libinput CLI tooling
    brightnessctl # Control brightness of things
    conntrack-tools # Connection tracking userspace tools
    iptstate # Conntrack "top like" tool
    nixos-generators # Tools for generating nixos images (AWS, Azure, ISO etc..)
    archiver # "Generic" decompression tool
    unzip # Decompress zip files
    unrar # Decompress rar files
    libressl # Crypto library, userspace tools
    fsql # Query the filesystem with SQL
    pstree # Show process tree as a tree
    gist # Tool to post files to gist.github.com straight away

    # Programming tools
    kdiff3 # Well know diffing tool

    # System tools
    putty # TTY tool for uncool people
    ark # Archiving tool
    gparted # GUI partition manager
    wireshark # Defactor network traffic sniffing tool
    nix-bash-completions # Nix completions in bash
    bash-completion # Bash cli autocomplete
    hardinfo # Hardware information
    debootstrap # Bootstrap Debian based (deb package manager) Linux distros

    # Productivity tools
    mongodb-compass # MongoDB GUI
    dbeaver # SQL database GUI
    wezterm # Crossplatform terminal emulator, supports ligatures
    bitwarden # Password manger
    rofimoji # Emoji/Char picker for rofi
    filezilla # Free FTP/FTPS/SFTP software
    freerdp # Remote Desktop Protocol client
    qbittorrent # OpenSource Qt Bittorrent client
    okular # PDF viewer

    # Misc
    scrcpy # Print-screen tool
    winePackages.wayland # Win32 API compability layer for Linux
    wine64Packages.wayland # Win32 API compability layer for Linux
    gimp # Photoshop alternative
    webcamoid # Webcam application

    # Web browsers
    firefox # The browser I'd love to use
    google-chrome # Only use this when websites are stupid

    # Games
    superTuxKart # Kart game with Tux
  ];

  fonts = {
    fontDir.enable = true;
    enableDefaultPackages = true;
    enableGhostscriptFonts = true;

    packages = with pkgs; [
      corefonts
      (
        nerdfonts.override {
          fonts = [ "Hack" "FiraCode" "DroidSansMono" ];
        }
      )
      helvetica-neue-lt-std
      font-awesome
    ];
  };

  environment.variables = {
    VISUAL = "nvim";
    ARM_THREEPOINTZERO_BETA_RESOURCES = "true";
  };

  # Enable SSH agent
  programs.ssh.startAgent = true;
  # Enable wireshark
  programs.wireshark.enable = true;
  # gnupg settings
  programs.gnupg.agent = {
    enable = true;
    pinentryFlavor = "qt";
  };
  # Bash autocomplete
  programs.bash.enableCompletion = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;

  # Local network autodiscovery services
  # required for chromecasting to work
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

  # Configure timeservers
  services.ntp = {
    enable = true;
    servers = [
      "0.se.pool.ntp.org"
      "1.se.pool.ntp.org"
      "2.se.pool.ntp.org"
      "3.se.pool.ntp.org"
    ];
  };

  security.pam.loginLimits = [
    {
      # This fixes "ip vrf exec"
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
        # Allow running htop --readonly as sudoer without password
        users = [ "lillecarl" ];
        commands = [
          {
            command = "${pkgs.htop}/bin/htop --readonly";
            options = [ "NOPASSWD" ];
          }
          {
            command = "${pkgs.ddcutil}/bin/ddcutil";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };

  # enable tailscale daemon
  services.tailscale.enable = true;

  # rtkit for pipewire? (Recommended on NixOS wiki)
  security.rtkit.enable = true;
  # Enable Flatpak
  services.flatpak.enable = true;
  # xdg desktop intergration (required for flatpak)
  xdg.portal.enable = true;
  # Enabled fwupd daemon, allows applications to update firmware
  services.fwupd.enable = true;
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  # Enable PipeWire A/V daemon
  # replaces all other sound daemons

  services.pipewire = {
    enable = true;
    alsa.enable = true; # Required by: Audacity
    jack.enable = true; # Required by: Qtractor
    pulse.enable = true;
    wireplumber.enable = true;
    socketActivation = true;
    systemWide = false;
  };
}
