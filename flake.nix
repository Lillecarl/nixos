{
  inputs = {
    # Direct inputs
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixos-facter-modules.url = "github:nix-community/nixos-facter-modules";
    ucodenix.url = "github:e-tho/ucodenix";
    nixng = {
      url = "github:nix-community/NixNG";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.treefmt-nix.follows = "treefmt-nix";
    };
    kubenix = {
      url = "github:hall/kubenix/main";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "";
      };
    };
    terranix = {
      url = "github:terranix/terranix/main";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        systems.follows = "nix-systems";
      };
    };
    nixpkgs-terraform-providers-bin = {
      url = "github:nix-community/nixpkgs-terraform-providers-bin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin-nix = {
      url = "github:catppuccin/nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs = {
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
        treefmt-nix.follows = "treefmt-nix";
      };
    };
    nixos-anywhere = {
      url = "github:nix-community/nixos-anywhere";
      inputs = {
        disko.follows = "disko";
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
        treefmt-nix.follows = "treefmt-nix";
      };
    };
    system-manager = {
      url = "github:numtide/system-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "flake-utils";
      inputs.flake-compat.follows = "flake-compat";
    };
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    nixvirt = {
      url = "github:AshleyYakeley/NixVirt";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noshell = {
      url = "github:viperML/noshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Get this working with newer k3s and go versions
    nix-snapshotter = {
      url = "github:pdtpartners/nix-snapshotter";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.flake-compat.follows = "flake-compat";
    };
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "nixpkgs-stable";
      };
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs-lib";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mozilla-addons-to-nix = {
      url = "sourcehut:~rycee/mozilla-addons-to-nix";
      inputs = {
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
        pre-commit-hooks.follows = "git-hooks";
      };
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs = {
        crane.follows = "crane";
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
        pre-commit-hooks-nix.follows = "git-hooks";
        rust-overlay.follows = "rust-overlay";
        flake-compat.follows = "flake-compat";
      };
    };
    catppuccin-qt5ct = {
      url = "github:catppuccin/qt5ct";
      flake = false;
    };

    # Indirect inputs
    nix-community-lib.url = "github:nix-community/nixpkgs.lib";
    nix-systems.url = "github:nix-systems/default-linux";
    nixpkgs-lib.url = "github:NixOS/nixpkgs/nixos-unstable?dir=lib";
    crane.url = "github:ipetkov/crane";
    flake-compat.url = "github:edolstra/flake-compat";
    ixx = {
      url = "github:NuschtOS/ixx";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    nuschtosSearch = {
      url = "github:NuschtOS/search";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.ixx.follows = "flake-utils";
    };
    nix-github-actions = {
      url = "github:nix-community/nix-github-actions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    cachix = {
      url = "github:cachix/cachix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        git-hooks.follows = "git-hooks";
        flake-compat.follows = "flake-compat";
        devenv.follows = "";
      };
    };
    crate2nix = {
      url = "github:nix-community/crate2nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        devshell.follows = "devshell";
        crate2nix_stable.follows = "";
        pre-commit-hooks.follows = "git-hooks";
        cachix.follows = "cachix";
        flake-compat.follows = "flake-compat";
      };
    };
    gitignore = {
      url = "github:hercules-ci/gitignore.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "nix-systems";
        darwin.follows = "nix-darwin";
        home-manager.follows = "home-manager";
      };
    };
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs = {
        flake-compat.follows = "flake-compat";
        gitignore.follows = "gitignore";
        nixpkgs.follows = "nixpkgs";
      };
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "nix-systems";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-eval-jobs = {
      url = "github:nix-community/nix-eval-jobs/main";
      inputs.flake-parts.follows = "flake-parts";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.treefmt-nix.follows = "treefmt-nix";
      inputs.nix-github-actions.follows = "nix-github-actions";
    };
  };

  outputs =
    inputs:
    let
      # limits perSystem
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      # Same settings for all nixpkgs instances
      pkgsSettings = system: {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          (import ./lib/overlay.nix inputs.self.outPath)
          (import ./pkgs)
          # inputs.nix-snapshotter.overlays.default
          inputs.nixgl.overlay
          inputs.nur.overlays.default
        ];
      };

      flakeloc =
        let
          loc = builtins.getEnv "FLAKE";
        in
        if builtins.stringLength loc == 0 then
          builtins.throw ''
            FLAKE environment variable is 0 length or not set at all, please
            set FLAKE to the repository root and evaluate with --impure
          ''
        else
          loc;
      slib = import ./lib {
        inherit (inputs.nixpkgs) lib;
        outPath = ./.;
      };
      imports = [
        ./checks/flake-module.nix
        ./fmt/flake-module.nix
        ./hosts/hetzner/flake-module.nix
        ./hosts/penguin/flake-module.nix
        ./hosts/shitbox/flake-module.nix
        ./repl/flake-module.nix
        ./repoenv/flake-module.nix
        ./users/lillecarl/flake-module.nix
      ];

      # Passed to flake-parts modules
      specialArgs = {
        inherit flakeloc slib;
      };
    in
    inputs.flake-parts.lib.mkFlake
      {
        inherit inputs;
        inherit specialArgs;
      }
      {
        inherit systems imports;
        flake = { };
        perSystem =
          {
            self',
            inputs',
            system,
            ...
          }:
          let
            pkgsGenerator = input: system: import input (pkgsSettings system);

            pkgs = pkgsGenerator inputs.nixpkgs system;
            mpkgs = pkgsGenerator inputs.nixpkgs-master system;
            spkgs = pkgsGenerator inputs.nixpkgs-stable system;

            legacyPackages = pkgs.extend (import ./pkgs);
            packages = import ./pkgs/pkgs.nix legacyPackages legacyPackages true;
          in
          {
            _module.args = {
              inherit pkgs mpkgs spkgs;
              mypkgs = inputs.nixpkgsOnFS or inputs.nixpkgs;
            } // specialArgs;

            inherit legacyPackages packages;
          };
      };
}
