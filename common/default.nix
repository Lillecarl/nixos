{ config, pkgs, lib, nixos-unstable-channel, ... }:
let
  braveWaylandDesktopItem = pkgs.makeDesktopItem {
    name = "brave-browser";
    desktopName = "Brave";
    icon = "brave-browser";
    mimeTypes = lib.splitString ";" "application/pdf;application/rdf+xml;application/rss+xml;application/xhtml+xml;application/xhtml_xml;application/xml;image/gif;image/jpeg;image/png;image/webp;text/html;text/xml;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ipfs;x-scheme-handler/ipns";
    exec = "${pkgs.brave}/bin/brave --ozone-platform=wayland %U";
  };

  slackWaylandDesktopItem = pkgs.makeDesktopItem {
    name = "slack";
    desktopName = "Slack";
    icon = "${pkgs.slack}/share/pixmaps/slack.png";
    mimeTypes = lib.splitString ";" "x-scheme-handler/slack";
    exec = "${pkgs.slack}/bin/slack --ozone-platform=wayland %U";
  };

  codeWaylandDesktopItem = pkgs.makeDesktopItem {
    name = "code";
    desktopName = "Visual Studio Code";
    icon = "code";
    mimeTypes = lib.splitString ";" "text/plain;inode/directory";
    exec = "${pkgs.vscode}/bin/code --ozone-platform=wayland %U";
  };

  programs_sqlite = pkgs.runCommandLocal "programs_sqlite" { } ''
    cp ${nixos-unstable-channel}/programs.sqlite $out
  '';

  python3Packages = pkgs.python310.pkgs;

  xonsh-direnv = python3Packages.buildPythonPackage rec {
    pname = "xonsh-direnv";
    version = "1.6.1";
    src = python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "sha256-Nt8Da1EtMVWZ9mbBDjys7HDutLYifwoQ1HVmI5CN2Ww=";
    };
    meta = {
      description = "xonsh extension for using direnv";
      homepage = "https://github.com/Granitosaurus/${pname}";
      license = lib.licenses.mit;
    };
  };

  xontrib-argcomplete = python3Packages.buildPythonPackage rec {
    pname = "xontrib-argcomplete";
    version = "0.3.2";
    src = python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "sha256-jn1NHh/PTTgSX0seOvOZTpRv4PxAQ4PbDiXOSb4/jrU=";
    };

    propagatedBuildInputs = with pkgs.python3Packages; [
      argcomplete
    ];

    meta = {
      description = "Argcomplete support for python and xonsh scripts in xonsh shell.";
      homepage = "https://github.com/anki-code/${pname}";
      license = lib.licenses.mit;
    };
  };

  tokenize-output = python3Packages.buildPythonPackage rec {
    pname = "tokenize-output";
    version = "0.4.7";
    src = python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "sha256-b/ffh5l6YO9A20vtekBGXLMZdfXfrzU9nzXyxa7xZR0=";
    };

    propagatedBuildInputs = with pkgs.python3Packages; [
      demjson3
    ];

    meta = {
      description = "Get identifiers, paths, URLs and words from a string.";
      homepage = "https://github.com/anki-code/${pname}";
      license = lib.licenses.mit;
    };
  };

  xontrib-output-search = python3Packages.buildPythonPackage rec {
    pname = "xontrib-output-search";
    version = "0.6.2";
    src = python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "sha256-Zh4DXs5qajZ3bR2YVJ+uLE2u1TVJcmdzH3x9nX6jJDI=";
    };

    propagatedBuildInputs = with pkgs.python3Packages; [
      tokenize-output
    ];

    meta = {
      description = "Get identifiers, paths, URLs and words from the previous command output and use them for the next command in xonsh shell.";
      homepage = "https://github.com/anki-code/${pname}";
      license = lib.licenses.mit;
    };
  };

  xontrib-fzf-widgets = python3Packages.buildPythonPackage rec {
    pname = "xontrib-fzf-widgets";
    version = "0.0.4";
    src = python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "sha256-EpeOr9c3HwFdF8tMpUkFNu7crmxqbL1VjUg5wTzNzUk=";
    };

    meta = {
      description = "fzf widgets for xonsh.";
      homepage = "https://github.com/laloch/${pname}";
      license = lib.licenses.mit;
    };
  };

  pyyaml = python3Packages.buildPythonPackage rec {
    pname = "PyYAML";
    version = "6.0";
    src = python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "sha256-aPtRnBQwb+yXIKKltFvJ8MjRuccq30XDe67fzZScNaI=";
    };

    meta = {
      description = "fzf widgets for xonsh.";
      homepage = "https://github.com/laloch/${pname}";
      license = lib.licenses.mit;
    };
  };

  repassh = python3Packages.buildPythonPackage rec {
    pname = "repassh";
    version = "1.2.0";
    src = python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "sha256-uerGQg/c+7LkDyenSeLjPaMMVCNZyMPw1atxhiQrIYI=";
    };

    meta = {
      description = "SSH agent integration for xonsh";
      homepage = "https://github.com/dyuri/${pname}";
      license = lib.licenses.mit;
    };
  };

  xontrib-ssh-agent = python3Packages.buildPythonPackage rec {
    pname = "xontrib-ssh-agent";
    version = "1.0.13";
    src = python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "sha256-XfrZ1ALl71anA/WeOAIBlifAE9ruoZPqD/blkJlf5fw=";
    };

    propagatedBuildInputs = with pkgs.python3Packages; [
      repassh
    ];
    meta = {
      description = "SSH agent integration for xonsh";
      homepage = "https://github.com/dyuri/${pname}";
      license = lib.licenses.mit;
    };
  };

  xontrib-sh = python3Packages.buildPythonPackage rec {
    pname = "xontrib-sh";
    version = "0.3.0";
    src = python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "sha256-eV++ZuopnAzNXRuafXXZM7tmcay1NLBIB/U+SVrQV+U=";
    };

    meta = {
      description = "SSH agent integration for xonsh";
      homepage = "https://github.com/anki-code/${pname}";
      license = lib.licenses.mit;
    };
  };

  xonsh-overlay = final: prev: {
    xonsh =
      let
        python3Packages = final.python310.pkgs;
      in
      (prev.xonsh.override { inherit python3Packages; }).overrideAttrs (old: {
        propagatedBuildInputs = lib.flatten [
          (with python3Packages; [
            xonsh-direnv
            xontrib-argcomplete
            xontrib-output-search
            xontrib-fzf-widgets
            xontrib-ssh-agent
            xontrib-sh
            pyyaml
            psutil
            jinja2
          ])
          (old.propagatedBuildInputs or [ ])
        ];
        checkInputs = [ ];
        checkPhase = "";
        pytestcheckPhase = "";
      });
  };
in
rec
{
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

  nixpkgs.overlays = [
    xonsh-overlay
  ];

  users.defaultUserShell = pkgs.zsh;
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

  programs.command-not-found.dbPath = programs_sqlite;

  # Give applications 15 seconds to shut down when shutting down the computer
  systemd.extraConfig = ''
    DefaultTimeoutStopSec=15s
  '';

  # Tailscale exit-node & subnet routing fix (asym routing)
  networking.firewall.checkReversePath = "loose";

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

  # Enable xwayland, not everything is wayland yet.
  programs.xwayland.enable = true;
  # Enable the X11 windowing system.
  services.xserver.enable = true;
  # Enable the Plasma 5 Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  services.xserver.desktopManager.plasma5.runUsingSystemd = true;
  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput = {
    enable = true;

    touchpad.disableWhileTyping = true;
  };

  # Configure keymap in X11
  services.xserver.layout = "us";
  # Allow local clients to connect to my X server
  services.xserver.displayManager.setupCommands = ''
    ${pkgs.xorg.xhost}/bin/xhost +local:
  '';
  # Replace caps-lock with caps
  services.xserver.xkbOptions = "esc:swapcaps";
  # Disable network-manager wait-online service that prohibits nixos-rebuild
  systemd.services.NetworkManager-wait-online.enable = false;

  # Use xserver keymap
  console = {
    useXkbConfig = true;
  };

  # XDG Base Directory Specification
  environment.sessionVariables = rec {
    XDG_CACHE_HOME = "\${HOME}/.cache";
    XDG_CONFIG_HOME = "\${HOME}/.config";
    XDG_BIN_HOME = "\${HOME}/.local/bin";
    XDG_DATA_HOME = "\${HOME}/.local/share";
    XDG_STATE_HOME = "\${HOME}/.local/state";
    NODE_HOME = "\${HOME}/.local/node";

    PATH = [
      "\${XDG_BIN_HOME}"
    ];

    POWERSHELL_TELEMETRY_OPTOUT = "yes";
  };

  # Firejail is used to isolate processes
  programs.firejail = {
    enable = true;
    wrappedBinaries = {
      teams_nent = {
        executable = "${lib.getBin pkgs.teams}/bin/teams";
        profile = "${pkgs.firejail}/etc/firejail/teams.profile";
        extraArgs = [ "--private=~/.local/share/teams_nent" ];
      };
    };
  };

  environment.systemPackages = with pkgs; [
    # Temporary lab
    (hiPrio braveWaylandDesktopItem) # Dekstop item to force Wayland
    (hiPrio slackWaylandDesktopItem) # Desktop item to force Wayland
    (hiPrio codeWaylandDesktopItem) # Desktop item to force Wayland
    xorg.xwininfo # Information about X windows (Used to find things using XWayland)
    xonsh

    tangram # Pinned tabs

    # Chat apps
    element-desktop # Element Slack app
    teams # Microsoft Teams collaboration suite (Electron)
    slack # Team collaboration chat (Electron)
    discord # Gaming chat application
    zoom # Meetings application
    signal-desktop # Secure messenger

    # Media apps
    mpv # Media Player
    celluloid #  MPV GTK frontend wrapper
    #vlc # VLC sucks in comparision to MPV

    # Commandline tools (CLI)
    execline # Tools for dbus n stuff
    actkbd # Keyboard shortcut daemon
    handlr # xdg-open alternative 
    cookiecutter # Simple project template engine
    distrobuilder # Build other distros
    x11docker # Run GUI applications with docker
    asciinema # Terminal session recorder
    asciinema-scenario # Make video from a text file
    xorg.xmodmap # Remapping keys in X
    mongodb-tools # MongoDB tools like dumping etc.
    starship # Shell prompt
    mcfly # Improved shell history
    bat # Cat clone with syntax highlight and git integration
    proxychains-ng # Proxy things through SOCKS
    sl # Train riding over screen in CLI
    cowsay # Make a cow say shit
    fortune # Fortune cookies in CLI
    toilet # Ascii art text
    cmatrix # Cool matrix style scrolling, really cpu intense
    tealdeer # Like, TL;DR manpages
    xprintidle-ng # print idle time
    envsubst # Templating with environment variables, commonly used with k8s
    wireguard-tools # Wireguard tools
    go # Golang
    dotnet-sdk_6 # Latest dotnet
    azure-cli # Azure CLI tooling
    awscli2 # AWS CLI tooling
    aws-nuke # Nuke AWS account completely
    #terraform # Cloud orchestrator
    tfswitch # Terraform version switcher
    terragrunt # Terraform Wrapper that does nice things
    youtube-dl # Download media from a lot of different websites
    zellij # discoverable terminal multiplexer written in rust
    zoxide # Rust implementation of z/autojump
    age # Modern crypto written in Go
    rage # Modern crypto written in Rust (Compatible with Age)
    chezmoi # dotfile manager
    pmutils # Suspend tools
    inotify-tools # CLI tools for inotify in Linux
    sshfs # Mount SFTP as filesystem
    rclone # rsync for clouds (+ loads of other cool things)
    k2tf # Kubernetes YAML to Terraform
    tfk8s # Kubernetes YAML to Terraform
    kubernetes-helm # Kubernetes package manager
    kompose # Kubernetes docker-compose like tool
    (lowPrio kubectl) # Kubernetes management cli
    kubectx # Kube switcher
    kubernetes # Kubernetes packages
    cmctl # cert-manager CLI
    krew # kubectl plugin manager
    operator-sdk # Kubernetes Operator Lifecycle Management(OLM) SDK
    packer # Tool to create images and stuff from Hashicorp
    gnumake # Make for packer for rhel template
    exa # cat replacement
    sipcalc # Subnet calculator
    buildah # Build OCI images
    debootstrap # Create Debian system in a chroot/systemd-nspawn
    bind # brings the dig command
    dogdns # dig without poop
    whois # whois command
    xortool # xor key bruteforcing tool
    (lowPrio wireshark-cli) # Wireshark CLI
    (lowPrio termshark) # Wireshark TUI?
    #libguestfs-with-appliance # Mount qcow2
    entr # Run commands when files change
    pv # Monitor pipe progress
    cmatrix # Just scrolling to look really cool
    mailutils # Sending mail from commandline 
    libnotify # Cli utils for sending KDE notifications
    vim # Modal CLI text editor
    neovim # Modal CLI text editor, modern version of Vim
    amp # Modal CLI text editor, modern, rust
    kakoune # Modal editor, faster because of fewer keystrokes
    helix #  Modern modal editor, written in Rust
    direnv # Tool for setting env-vars when entering directories
    emacs # well, it's emacs...
    fd # not sure, doom-emacs recommends it
    ripgrep # Modern rusty grep
    lsof # Check who uses file
    ripgrep # Rust grep implmenetation, not POSIX compliant
    wget # Fetch things quicly with HTTP
    gnufdisk # CLI partition management (MBR)
    gptfdisk # CLI partition management (GPT)
    efitools # Tools for managing EFI, variables and such
    curl # All things HTTP and other web transfer protocols
    tmux # terminal multiplexer
    tmate # terminal multiplexer with online sharing
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
    nix-direnv # Nix direnv implementation
    nix-prefetch # nix prefetcher
    nix-prefetch-github # fetch nix package from github
    comma # Run stuff without installing it
    niv # Dependency manager for Nix, which is a dependency manager (wat)
    lorri # nix-shell alternative
    direnv # Do environment things based on cd
    pijul # Patch based git alternative (Similiar to darcs but written in rust)
    gitFull # Git and all beloning standard packages
    lazygit # Git TUI, golang
    gitui # Git TUI, rust
    overcommit # Git hooks manager
    github-cli # CLI for github interactions
    git-open # Open repo with browser in $sourcecontrol website
    git-imerge # interactive and incremental git merging utility
    git-trim
    git-cola
    git-fire # Save your code, then your life
    bfg-repo-cleaner # Clean repos that are huge
    alacritty # Fast crossplatform terminal emulator
    xclip # | "xclip -sel clip" is what you want
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
    powershell # Microsofts shell implementation
    ncdu # NCurses Disk Utility (TUI way of finding big files and folders)
    scrot # Commandline print-screen tool, use with GnuPG for automatic screenshotting
    maim # Commandline print-screen tool, use with GnuPG for automatic screenshotting
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
    keychain # Easier key management
    ranger # file manager
    nnn # file manager
    fzf # fuzzy finder, pipe to this for nice search
    unipicker # unicode char finder
    bitwarden-cli # Password manager CLI
    thefuck # Command that corrects your previous command
    speedtest-cli # Speedtest from the commandline
    poppler_utils # Utilities for PDF rendering
    imagemagick # CLI for doing image stuff
    waypipe # Wayland forwarding (Like X11 forwarding, but for Wayland)
    xbindkeys # Binding keys for X
    xorg.xev # Monitor Keypresses, useful when troubleshooting keylayouts
    xorg.xhost # Not sure, used for X11 socket forwarding
    xorg.xinit # Well starting x?
    libinput # Libinput CLI tooling
    brightnessctl # Control brightness of things
    conntrack-tools # Connection tracking userspace tools
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
    ruby # Ruby programming language
    #python3 # Language interpreter
    #python39Packages.boto3 # AWS Python library
    nodejs # Javascript with OS access
    #gnumake # GNU make
    #clang # Cool modular C/C++ compiler
    #(lowPrio gcc) # Old but gold C/C++ and others compiler

    # System tools
    ark # Archiving tool
    gparted # GUI partition manager
    wireshark # Defactor network traffic sniffing tool
    ksystemlog # KDE syslog viewer
    #etcher # Balena Etcher, GUI for dd (flash SD cards)
    nix-bash-completions # Nix completions in bash
    nix-zsh-completions # Nix completions in ZSH
    bash-completion # Bash cli autocomplete
    hardinfo # Hardware information
    debootstrap # Bootstrap Debian based (deb package manager) Linux distros

    # Productivity tools
    tigervnc # VNC client
    #opensnitch-ui
    mongodb-compass # MongoDB GUI
    dbeaver # SQL database GUI
    #pgadmin4 # SQL database GUI
    wezterm # Crossplatform terminal emulator, supports ligatures
    bitwarden # Password manger
    rofi # Searchable window title window switcher
    rofimoji # Emoji/Char picker for rofi
    gitkraken # Git GUI
    #claws-mail # Mail client
    #evolution # Mail client
    #mailspring # Mail client
    libreoffice # MS office compatible productivity suite
    obs-studio # Screen recording/streaming utility
    filezilla # Free FTP/FTPS/SFTP software
    freerdp # Remote Desktop Protocol client
    kgpg # KDE pgp tool
    copyq # Clipboard manager
    qview # Image viewer
    kate # KDE text editor
    notepadqq # Notepad++ "clone" for Linux
    geany # Supposed to be like Notepad++
    ghostwriter # Markdown editor
    #teamviewer # Remote Desktop Solution
    audacity # Audio software
    qtractor # Audio software
    qbittorrent # OpenSource Qt Bittorrent client
    #subdl # Download subtitles
    okular # PDF viewer
    libsForQt5.kcolorpicker # Color Picker for Qt/KDE
    colorpicker # Just a color picker

    # Misc
    xdg-desktop-portal-kde # KDE portal (portals seem to be a Flatpak thing)
    plasma-browser-integration # KDE browser integration
    scrcpy # Print-screen tool
    winePackages.wayland # Win32 API compability layer for Linux
    wine64Packages.wayland # Win32 API compability layer for Linux
    bottles # Wine prefix manager (Tool to make installing Windows apps easier)
    krita # KDE alternative to GIMP
    gimp # Photoshop alternative
    kdenlive # KDE alternative to Windows Movie Maker
    webcamoid # Webcam application
    mkchromecast # Chromecast CLI
    gnomecast # Chromecast CLI
    go-chromecast # Chromecast CLI
    castnow # Chromecast CLI
    catt # Chromecast CLI

    # Web browsers
    brave # Web brower, Chromium based
    firefox # The browser I'd love to use
    google-chrome # Only use this when websites are stupid
    nyxt # Hackable "power-browser"
    qutebrowser # Keyboard driven browser, Python and PyQt based

    # Games
    superTuxKart # Kart game with Tux
  ];

  fonts = {
    fontDir.enable = true;
    enableDefaultFonts = true;
    enableGhostscriptFonts = true;

    fonts = with pkgs; [
      corefonts
      nerdfonts
      powerline-fonts
      helvetica-neue-lt-std
      xkcd-font
      hack-font
      fira-code
      fira-code-symbols
      jetbrains-mono
      unifont
    ];
  };

  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    ARM_THREEPOINTZERO_BETA_RESOURCES = "true";
  };

  # Enable SSH agent
  programs.ssh.startAgent = true;
  # Enable KDE Connect
  programs.kdeconnect.enable = true;
  # Enable noisetorch, noise suppression for microphones using pulse/pipewire
  #programs.noisetorch.enable = true;
  # Enable wireshark
  programs.wireshark.enable = true;
  # gnupg settings
  programs.gnupg.agent = {
    enable = true;
    pinentryFlavor = "qt";
  };
  # Enable xonsh
  programs.xonsh.enable = true;
  # Enable zsh
  programs.zsh.enable = true;
  # Bash autocomplete
  programs.bash.enableCompletion = true;

  # Enable Oh-my-zsh
  programs.zsh.ohMyZsh = {
    enable = true;
    plugins = [ "git" "sudo" "docker" "kubectl" ];
  };

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

  # Network Firewall
  #services.opensnitch.enable = true;

  security.pam.loginLimits = [
    {
      # This fixes "ip vrf exec" for reasons still "unknown" (haven't read up on yet)
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
  xdg.portal = {
    enable = true;
    #gtkUsePortal = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
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
    wireplumber.enable = true;
  };
}
