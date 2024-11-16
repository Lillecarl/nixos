{
  inputs = {
    nix-community-lib.url = "github:nix-community/nixpkgs.lib";
    nix-systems.url = "github:nix-systems/default-linux";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixpkgs-lib.url = "github:NixOS/nixpkgs/nixos-unstable?dir=lib";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    #nixpkgs.url = "/home/lillecarl/Code/nixpkgs";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-23.11";
    nur.url = "github:nix-community/NUR";
    nix-flatpak.url = "github:gmodena/nix-flatpak";
    get-flake.url = "github:ursi/get-flake";
    catppuccin-nix.url = "github:catppuccin/nix";
    crane.url = "github:ipetkov/crane";

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
    wrapper-manager = {
      url = "github:viperML/wrapper-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Get this working with newer k3s and go versions
    nix-snapshotter = {
      url = "github:pdtpartners/nix-snapshotter";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };
    nix-github-actions = {
      url = "github:nix-community/nix-github-actions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    cachix = {
      url = "github:cachix/cachix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
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
        pre-commit-hooks.follows = "pre-commit-hooks";
        cachix.follows = "cachix";
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
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
        nix-darwin.follows = "nix-darwin";
        flake-parts.follows = "flake-parts";
        devshell.follows = "devshell";
        treefmt-nix.follows = "treefmt-nix";
      };
    };
    nypkgs = {
      url = "github:yunfachi/nypkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "nixpkgs-stable";
        flake-parts.follows = "flake-parts";
      };
    };
    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "nix-systems";
        darwin.follows = "darwin";
        home-manager.follows = "home-manager";
      };
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs = {
        gitignore.follows = "gitignore";
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "nixpkgs-stable";
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
    nixos-wsl = {
      url = "github:nix-community/nixos-wsl";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-eval-jobs = {
      url = "github:nix-community/nix-eval-jobs/main";
      inputs.flake-parts.follows = "flake-parts";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.treefmt-nix.follows = "treefmt-nix";
      inputs.nix-github-actions.follows = "nix-github-actions";
    };
    lib-aggregate = {
      url = "github:nix-community/lib-aggregate/master";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs-lib.follows = "nix-community-lib";
    };
    terranix = {
      url = "github:terranix/terranix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-wayland = {
      url = "github:nix-community/nixpkgs-wayland";
      inputs = {
        lib-aggregate.follows = "lib-aggregate";
        nix-eval-jobs.follows = "nix-eval-jobs";
        nixpkgs.follows = "nixpkgs";
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
        pre-commit-hooks.follows = "pre-commit-hooks";
      };
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs = {
        crane.follows = "crane";
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
        pre-commit-hooks-nix.follows = "pre-commit-hooks";
        rust-overlay.follows = "rust-overlay";
      };
    };

    carapace = {
      url = "github:rsteube/carapace-bin";
      flake = false;
    };
    nixos-artwork = {
      url = "github:NixOS/nixos-artwork";
      flake = false;
    };
    catppuccin-qt5ct = {
      url = "github:catppuccin/qt5ct";
      flake = false;
    };
  };

  outputs =
    { self
    , flake-parts
    , ...
    } @ inputs:
    let
      # limits perSystem
      systems = [
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      # Same settings for all nixpkgs instances
      pkgsSettings = system: {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          (import ./lib/overlay.nix self.outPath)
          (import ./pkgs)
          inputs.nix-snapshotter.overlays.default
          inputs.nixgl.overlay
          inputs.nur.overlay
        ];
      };

      pkgsGenerator = input: system: import input (pkgsSettings system);

      flakeloc = import ./.flakepath;
      flakepath = ./.;
      slib = import ./lib { inherit (inputs.nixpkgs) lib; outPath = ./.; };
      imports = slib.rimport { path = ./.; regadd = "^.*flake-module.*\.nix$"; };

      # Passed to flake-parts modules
      specialArgs = {
        inherit flakeloc flakepath slib;
      };
    in
    flake-parts.lib.mkFlake
      {
        inherit inputs;
        inherit specialArgs;
      }
      {
        inherit systems imports;
        flake = { };
        perSystem =
          { config
          , system
          , pkgs
          , mpkgs
          , spkgs
          , inputs'
          , withSystem
          , ...
          }:
          let
            legacyPackages = pkgs.extend (import ./pkgs);
            packages = import ./pkgs/pkgs.nix legacyPackages legacyPackages true;
          in
          {
            _module.args = {
              pkgs = pkgsGenerator inputs.nixpkgs system;
              mpkgs = pkgsGenerator inputs.nixpkgs-master system;
              spkgs = pkgsGenerator inputs.nixpkgs-stable system;
            } // specialArgs;

            formatter = pkgs.nixpkgs-fmt;
            inherit legacyPackages packages;
          };
      };
}
