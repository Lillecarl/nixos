{ pkgs
, mpkgs
, inputs
, ...
}: {
  home.packages = with pkgs; [
    #httpie # A modern, user-friendly command-line HTTP client for the API era.
    #inputs.mozilla-addons-to-nix.packages.x86_64-linux.default
    #inputs.system-manager.packages.x86_64-linux.system-manager
    inputs.agenix.packages.${pkgs.system}.default
    nix-melt # nix flake viewer
    mimeo # Open files with the right program
    (lowPrio kubectl) # Kubernetes management cli
    gdb # GNU debugger
    ngrok # reverse proxy
    pass # GPG based password store
    age # Modern crypto written in Go
    ansible-lint # Ansible linting software
    aws-vault # AWS Vault CLI (Used for MFA auth?)
    awscli2 # AWS cli tool
    broot # A new way to see and navigate directory trees
    choose # A human-friendly and fast alternative to cut and (sometimes) awk
    cmatrix # Cool matrix style scrolling, really cpu intense
    cmctl # cert-manager CLI
    colmena # Stateless Nix deploy tool
    cowsay # Make a cow say shit
    delta # Diffing software
    direnv # Do stuff on cd.
    du-dust # A more intuitive version of du written in rust.
    duf # A better df alternative
    envsubst # Templating with environment variables, commonly used with k8s
    eza # Better ls
    fd # A simple, fast and user-friendly alternative to find
    fortune # Fortune cookies in CLI
    fzf # fzf cli fuzzy search tool
    gh # Github CLI
    gitui # Fast Git TUI.
    gping # ping, but with a graph.
    gron # Flatten JSON to make it easy to grep
    htop # NCurses "task manager"
    jq # CLI JSON utility, piping JSON here will always pretty-print it
    k2tf # Kubernetes YAML to Terraform
    kompose # Kubernetes docker-compose like tool
    kubectx # Kube switcher
    kubernetes # Kubernetes packages
    kubernetes-helm # Kubernetes package manager
    kubevirt # virtctl tool for kubevirt
    openvpn # VPN software
    operator-sdk # Kubernetes Operator Lifecycle Management(OLM) SDK
    packer # Tool to create images and stuff from Hashicorp
    procs # A modern replacement for ps written in Rust.
    rage # Modern crypto written in Rust (Compatible with Age)
    ripgrep # Modern rusty grep
    scrcpy # Remote your android over adb
    tealdeer # tldr pages
    terragrunt # Some weird Terraform abstraction
    tfk8s # Kubernetes YAML to Terraform
    tfswitch # Terraform version switcher
    tmate # terminal multiplexer with online sharing
    toilet # Ascii art text
    jq # CLI JSON utility, piping JSON here will always pretty-print it
    github-cli # CLI for github interactions
    git-open # Open repo with browser in $sourcecontrol website
    git-imerge # interactive and incremental git merging utility
    bfg-repo-cleaner # Clean repos that are huge
    yq-go # CLI YAML utility, useful for those that thing YAML is a bit shit
    zellij # discoverable terminal multiplexer written in rust
    zoxide # Rust implementation of z/autojump
    statix # Nix linter
    unzip
    zip
    bubblewrap # flatpak without flatpak
    virtualenv # python environments
    nil # Nix language server, also CLI tool for diagnostics
    nvd # Nix closure diff
    nix-output-monitor # Nix output monitor
    ddcutil # change display settings
    lego # CLI ACME client
    socat # Socket tool
    iperf3 # Speedtest
    src-cli # Sourcegraph CLI
    skim # Modern rusty fzf
    dtach # Detach application from screen
    kind # Kubernetes in Docker (podman)
    jnv # Interactive jq
    hl # Terminal logfmt / json log tool
    cliphist # Clipboard history tool
    wofi # Rofi wayland
    moreutils # stdin -> file (usable w/ sudo)
    minicom # serial util
  ];
}
