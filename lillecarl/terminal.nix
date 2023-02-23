{ config, pkgs, ... }:
{
  home.file = {
    # Replace this list once https://github.com/nix-community/home-manager/pull/3235 is ready and merged
    ".config/xonsh/rc.xsh".source = ./dotfiles/.config/xonsh/rc.xsh;
    ".config/xonsh/rc.d/aliases.xsh".source = ./dotfiles/.config/xonsh/rc.d/aliases.xsh;
    ".config/xonsh/rc.d/keybindings.xsh".source = ./dotfiles/.config/xonsh/rc.d/keybindings.xsh;
    ".config/xonsh/rc.d/prompt.xsh".source = ./dotfiles/.config/xonsh/rc.d/prompt.xsh;
    ".config/powershell/Microsoft.PowerShell_profile.ps1".source = ./dotfiles/.config/powershell/Microsoft.PowerShell_profile.ps1;
    ".config/qtile/autostart.sh".source = ./dotfiles/.config/qtile/autostart.sh;
    ".config/qtile/config.py".source = ./dotfiles/.config/qtile/config.py;
    ".config/qtile/battery.py".source = ./dotfiles/.config/qtile/battery.py;
  };

  xdg = {
    enable = true;
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    enableExtraSocket = true;
  };

  programs.gpg = {
    enable = true;

    mutableKeys = true;
    mutableTrust = true;
  };

  programs.zellij = {
    enable = true;

    settings = { };
  };

  programs.neovim = {
    enable = true;

    vimAlias = true;
    viAlias = true;
    vimdiffAlias = true;
    defaultEditor = true;

    plugins = with pkgs.vimPlugins; [
      nvim-treesitter
      coc-pyright
      coc-clangd
    ];

    coc = {
      enable = true;

      settings = {
        languageserver = {
          nix = {
            command = "${pkgs.rnix-lsp}/bin/rnix-lsp";
            filetypes = [ "nix" ];
          };
          terraform = {
            command = "${pkgs.terraform-lsp}/bin/terraform-lsp";
            filetypes = [ "terraform" ];
            initializationOptions = { };
          };
          clangd = {
            command = "${pkgs.clang-tools}/bin/clangd";
            rootPatterns = [ "compile_flags.txt" "compile_commands.json" ];
            filetypes = [ "c" "cc" "cpp" "c++" "objc" "objcpp" ];
          };
        };
      };
    };

    extraConfig = ''
      set mouse=
      set number
      set encoding=utf-8
    '';
  };

  programs.starship = {
    enable = true;

    settings = {
      # We don't use terraform workspaces so don't consume the space
      terraform = {
        disabled = true;
      };

      # Directory config, truncation_length is subpath count not char count
      # don't truncate to git repo (not sure how i feel about this one yet)
      directory = {
        truncate_to_repo = false;
        truncation_length = 10;
      };

      # Show exit codes
      status = {
        disabled = false;
      };

      username = {
        format = "[$user]($style) on";
      };

      # Display which shell we're in
      # Do we actually need this? We use xonsh all the time.
      env_var.STARSHIP_SHELL = {
        format = "🐚 [$env_value]($style) ";
        style = "fg:green";
      };
    };
  };

  programs.tealdeer = {
    enable = true;

    settings = {
      display = {
        compact = false;
        use_pager = false;
      };

      updates = {
        auto_update = true;
        auto_update_interval_hours = 168;
      };
    };
  };

  programs.wezterm = {
    enable = true;

    extraConfig = ''
      return {
        check_for_updates = false,
        hide_tab_bar_if_only_one_tab = true,
        font = wezterm.font_with_fallback({
          'Hack Nerd Font',
          'Hack',
          'Unifont',
        }),
        font_size = 10,
        enable_wayland = true,
        skip_close_confirmation_for_processes_named = {
          'bash',
          'sh',
          'zsh',
          'fish',
          'xonsh',
          'tmux',
          'zellij',
        },
      }
    '';
  };

  programs.git = {
    enable = true;
    userName = "Carl Hjerpe";
    userEmail = "git@hjerpe.xyz";
    lfs.enable = true;

    signing = {
      key = "3916387439FCDA33";
      signByDefault = true;
    };
  };

  programs.rbw = {
    enable = true;
    settings = {
      email = "bitwarden@lillecarl.com";
      pinentry = "qt";
    };
  };

  home.packages = with pkgs; [
    salt-pepper # salt-api CLI tool
    xonsh-wrapped # xonsh shell
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
