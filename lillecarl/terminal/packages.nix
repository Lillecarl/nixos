{ config, pkgs, inputs, ... }:
{
  home.packages = with pkgs; [
    inputs.devenv.defaultPackage.x86_64-linux # devenv package
    carapace # completion engine
    salt-pepper # salt-api CLI tool
    xonsh-wrapped # xonsh shell
    moar # Better pager
    rbw # Unofficial Bitwarden CLI client
    delta # Diffing software
    du-dust # A more intuitive version of du written in rust.
    duf # A better df alternative
    broot # A new way to see and navigate directory trees
    fd # A simple, fast and user-friendly alternative to find
    bat # Better cat
    exa # Better ls
    direnv # Do stuff on cd.
    gitui # Fast Git TUI.
    choose # A human-friendly and fast alternative to cut and (sometimes) awk
    gping # ping, but with a graph.
    procs # A modern replacement for ps written in Rust.
    #httpie # A modern, user-friendly command-line HTTP client for the API era.
    ansible-lint # Ansible linting software
    cowsay # Make a cow say shit
    fortune # Fortune cookies in CLI
    toilet # Ascii art text
    cmatrix # Cool matrix style scrolling, really cpu intense
    envsubst # Templating with environment variables, commonly used with k8s
    fzf # fzf cli fuzzy search tool
    gh # Github CLI
    #awscli2 # AWS CLI tooling
    zellij # discoverable terminal multiplexer written in rust
    zoxide # Rust implementation of z/autojump
    age # Modern crypto written in Go
    rage # Modern crypto written in Rust (Compatible with Age)
    tfswitch # Terraform version switcher
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
    ripgrep # Modern rusty grep
    tmate # terminal multiplexer with online sharing
    htop # NCurses "task manager"
    jq # CLI JSON utility, piping JSON here will always pretty-print it
    yq # CLI YAML utility, useful for those that thing YAML is a bit shit
    gron # Flatten JSON to make it easy to grep
    node2nix # Generate nix packages from NPM packages
    nodePackages.pajv # JSON Schema Validator for multiple formats
  ];
}
