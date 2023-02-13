{ config, pkgs, ... }:
{
  home.file = {
    # Replace this list once https://github.com/nix-community/home-manager/pull/3235 is ready and merged
    ".config/xonsh/rc.xsh".source = ./dotfiles/.config/xonsh/rc.xsh;
    ".config/xonsh/rc.d/aliases.xsh".source = ./dotfiles/.config/xonsh/rc.d/aliases.xsh;
    ".config/xonsh/rc.d/keybindings.xsh".source = ./dotfiles/.config/xonsh/rc.d/keybindings.xsh;
    ".config/xonsh/rc.d/prompt.xsh".source = ./dotfiles/.config/xonsh/rc.d/prompt.xsh;
    ".config/starship.toml".source = ./dotfiles/.config/starship.toml;
    ".config/tealdeer/config.toml".source = ./dotfiles/.config/tealdeer/config.toml;
    ".config/powershell/Microsoft.PowerShell_profile.ps1".source = ./dotfiles/.config/powershell/Microsoft.PowerShell_profile.ps1;
    ".config/nvim/init.vim".source = ./dotfiles/.config/nvim/init.vim;
    ".config/wezterm/wezterm.lua".source = ./dotfiles/.config/wezterm/wezterm.lua;
    ".config/qtile/autostart.sh".source = ./dotfiles/.config/qtile/autostart.sh;
    ".config/qtile/config.py".source = ./dotfiles/.config/qtile/config.py;
    ".config/qtile/battery.py".source = ./dotfiles/.config/qtile/battery.py;
  };

  programs.git = {
    enable = true;
    userName = "Carl Hjerpe";
    userEmail = "git@hjerpe.xyz";
    lfs.enable = true;
  };

  programs.rbw = {
    enable = true;
    settings = {
      email = "bitwarden@lillecarl.com";
      pinentry = "qt";
    };
  };

  home.packages = with pkgs; [
    xonsh # xonsh shell
    moar # Better pager
    rbw # Unofficial Bitwarden CLI client
    delta # Diffing software
    du-dust # A more intuitive version of du written in rust.
    duf # A better df alternative
    broot # A new way to see and navigate directory trees
    fd # A simple, fast and user-friendly alternative to find
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
    awscli2 # AWS CLI tooling
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
