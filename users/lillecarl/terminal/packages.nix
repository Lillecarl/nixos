{
  lib,
  config,
  pkgs,
  inputs,
  nixosConfig,
  ...
}:
{
  config = lib.mkIf config.ps.terminal.enable {
    home.packages =
      with pkgs;
      (
        if config.ps.terminal.mode == "fat" then
          [
            autossh # Auto ssh connect stuff
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
            # opentofu # FLOSS Terraform
            config.lib.pspkgs.opentofu
            deploy-rs # Nix deploy tool
            waypipe # Wayland over SSH mostly for wl-clipboard
            kubectl # Kubernetes CLI
            kubectx # Kubernetes context switcher
            kubernetes-helm # Kubernetes package manager built in go templates
            k9s # Kubernetes TUI
            terranix # Nix -> config.tf.json
            kustomize # Kubernetes YAML wrangler
            stern # Better kubectl logs
            nerdctl # containerd cli tool
            kubelogin-oidc # Kubernetes OIDC login
            forgejo-cli # CLI for Forgejo (Gitea fork, codeberg.org)
            inputs.optnix.packages.${pkgs.system}.optnix # TUI Nix options searcher
            config.lib.pspkgs.cmctl # Cert-Manager
            config.lib.pspkgs.kubectl-cnpg # CloudnativePG
          ]
        else
          [ ]
      )
      ++ (
        if config.ps.terminal.mode == "slim" then
          [
            waypipe # Clipboard over SSH
            ncdu # Inspect disk usage
            rclone # Cloud storage
            wl-clipboard # CLI clipboard handling
            nvd # Nix diff tool
            nix-output-monitor # Nix build with progress
          ]
        else
          [ ]
      );
    lib.pspkgs.kubectl-cnpg = (
      pkgs.kubectl-cnpg.overrideAttrs (pattrs: rec {
        version = "1.25.0-rc1";

        src = pkgs.fetchFromGitHub {
          owner = "cloudnative-pg";
          repo = "cloudnative-pg";
          rev = "v${version}";
          hash = "sha256-j94AagvDEFsr/hbDZrDzXVdOJSF0Dnkd2djuK2vzIsU=";
        };

        vendorHash = "sha256-FJ2ugKL4u9sWQhDu/7Dxzms+XitiXwu3FSULTZh4qiA=";
      })
    );
    lib.pspkgs.cmctl = (
      pkgs.cmctl.overrideAttrs (pattrs: rec {
        version = "2.1.1";
        sourceRoot = src.name;

        src = pkgs.fetchFromGitHub {
          owner = "cert-manager";
          repo = "cmctl";
          rev = "v${version}";
          hash = "sha256-+bKU6WLemn0y8yp+qLUKmhA2cSqVZOrzXNiwkwx0+Nk=";
        };

        vendorHash = "sha256-6YecOYHBGZoAj9sUzYFN3MOsa7m5/jMBrOZrdvZTfao=";
        doCheck = false;
        postInstall = ''
          # Link as kubectl plugin
          ln -s $out/bin/cmctl $out/bin/kubectl_cert-manager
          # Install shell completions
          installShellCompletion --cmd cmctl \
            --bash <($out/bin/cmctl completion bash) \
            --fish <($out/bin/cmctl completion fish) \
            --zsh <($out/bin/cmctl completion zsh)
        '';
      })
    );

    lib.pspkgs.tfBin = inputs.nixpkgs-terraform-providers-bin.legacyPackages.${pkgs.system};
    lib.pspkgs.opentofu =
      let
        tfProviders = config.lib.pspkgs.tfBin.providers;
      in
      (pkgs.opentofu.withPlugins (
        _:
        builtins.map (p: p.override { registry = "registry.opentofu.org"; }) (
          with tfProviders;
          [
            alekc.kubectl
            cloudflare.cloudflare
            cyrilgdn.postgresql
            grafana.grafana
            hashicorp.http
            hashicorp.kubernetes
            hashicorp.local
            hashicorp.null
            hashicorp.random
            hashicorp.time
            hashicorp.vault
            hetznercloud.hcloud
            kbst.kustomization
            keycloak.keycloak
            loafoe.htpasswd
            maxlaverse.bitwarden
            metio.migadu
            random-things.string-functions
          ]
        )
        ++ [
          (pkgs.terraform-providers.mkProvider {
            owner = "iwarapter";
            repo = "terraform-provider-jwks";
            rev = "v0.1.0";
            spdx = "MIT";
            hash = "sha256-crIluhHmsNBYYzXM57z/Hmyln8QNpnVzNf6AyXILT9c=";
            vendorHash = "sha256-LMN+me0hq/XKT2Z20tKSeM531o47ez0a6S0ojdNrbd0=";
            homepage = "https://registry.opentofu.org/iwarapter/jwks";
          })
        ]
      ));
    lib.pspkgs.fish4 = (pkgs.callPackage "${inputs.nixpkgs-fish}/pkgs/by-name/fi/fish/package.nix" { });
    xdg.dataFile.tfplugins = {
      source = "${config.lib.pspkgs.opentofu}/libexec/terraform-providers";
      recursive = true;
    };
  };
}
