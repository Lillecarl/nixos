{
  lib,
  config,
  pkgs,
  mpkgs,
  inputs,
  nixosConfig,
  ...
}:
{
  config = lib.mkIf config.ps.terminal.enable {
    home.packages = with pkgs; [
      #httpie # A modern, user-friendly command-line HTTP client for the API era.
      #inputs.mozilla-addons-to-nix.packages.x86_64-linux.default
      #inputs.system-manager.packages.x86_64-linux.system-manager
      #inputs.agenix.packages.${pkgs.system}.default
      inputs.nix-auto-follow.packages.${pkgs.system}.default
      nixgl.nixGLMesa # OpenGL wrapper helper
      mimeo # Open files with the right program
      broot # A new way to see and navigate directory trees
      choose # A human-friendly and fast alternative to cut and (sometimes) awk
      direnv # Do stuff on cd.
      du-dust # A more intuitive version of du written in rust.
      duf # A better df alternative
      envsubst # Templating with environment variables, commonly used with k8s
      eza # Better ls
      fd # A simple, fast and user-friendly alternative to find
      fzf # fzf cli fuzzy search tool
      gitui # Fast Git TUI.
      gping # ping, but with a graph.
      gron # Flatten JSON to make it easy to grep
      htop # NCurses "task manager"
      jq # CLI JSON utility, piping JSON here will always pretty-print it
      k2tf # Kubernetes YAML to Terraform
      procs # A modern replacement for ps written in Rust.
      rage # Modern crypto written in Rust (Compatible with Age)
      ripgrep # Modern rusty grep
      scrcpy # Remote your android over adb
      tealdeer # tldr pages
      tmate # terminal multiplexer with online sharing
      toilet # Ascii art text
      jq # CLI JSON utility, piping JSON here will always pretty-print it
      yq-go # CLI YAML utility, useful for those that thing YAML is a bit shit
      zoxide # Rust implementation of z/autojump
      statix # Nix linter
      unzip # Archiver
      zip # Unarchiver
      nil # Nix language server, also CLI tool for diagnostics
      nvd # Nix closure diff
      nix-output-monitor # Nix output monitor
      ddcutil # change display settings
      socat # Socket tool
      iperf3 # Speedtest
      src-cli # Sourcegraph CLI
      skim # Modern rusty fzf
      dtach # Detach application from screen
      jnv # Interactive jq
      cliphist # Clipboard history tool
      moreutils # stdin -> file (usable w/ sudo)
      minicom # serial util
      just # make++
      graphviz-nox # Graphviz tools
      bintools # bin tools, like nm and such for reading ELF headers
      wl-clipboard # CLI utilities to copy/paste from wayland clipboard
      rclone # rsync for the cloud
      dogdns # CLI DNS tool
      entr # Do something when a file changes
      expect # Automate interactive applications (contains unbuffer and friends)
      ncdu # NCurses disk usage, like du but with a UI
      progress # Coreutils Progress Viewer
      opentofu # FLOSS Terraform
      deploy-rs # Nix deploy tool
      waypipe # Wayland over SSH mostly for wl-clipboard
      kubectl # Kubernetes CLI
      kubernetes-helm # Kubernetes package manager built in go templates
      (kubectl-cnpg.overrideAttrs (pattrs: rec {
        version = "1.25.0-rc1";

        src = fetchFromGitHub {
          owner = "cloudnative-pg";
          repo = "cloudnative-pg";
          rev = "v${version}";
          hash = "sha256-j94AagvDEFsr/hbDZrDzXVdOJSF0Dnkd2djuK2vzIsU=";
        };

        vendorHash = "sha256-FJ2ugKL4u9sWQhDu/7Dxzms+XitiXwu3FSULTZh4qiA=";
      }))
    ];
  };
}
