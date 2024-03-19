{
  inputs = {
    gitignore.url = "github:hercules-ci/gitignore.nix";
    nix-community-lib.url = "github:nix-community/nixpkgs.lib";
    nix-systems.url = "github:nix-systems/default-linux";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixpkgs-lib.url = "github:NixOS/nixpkgs/nixos-unstable?dir=lib";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";
    nix-flatpak.url = "github:gmodena/nix-flatpak";
    niri.url = "github:sodiboo/niri-flake";

    ags = {
      url = "github:Aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    pre-commit-hooks-nix = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs = {
        flake-utils.follows = "flake-utils";
        gitignore.follows = "gitignore";
        nixpkgs.follows = "nixpkgs";
      };
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "nix-systems";
    };
    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
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
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "github:nix-community/nixos-wsl";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-eval-jobs = {
      url = "github:nix-community/nix-eval-jobs/main";
      inputs.flake-parts.follows = "flake-parts";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lib-aggregate = {
      url = "github:nix-community/lib-aggregate/master";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs-lib.follows = "nix-community-lib";
    };
    # Use Nix as Terraform
    terranix = {
      url = "github:terranix/terranix";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Wayland packages for NixOS
    nixpkgs-wayland = {
      url = "github:nix-community/nixpkgs-wayland";
      inputs = {
        lib-aggregate.follows = "lib-aggregate";
        nix-eval-jobs.follows = "nix-eval-jobs";
        nixpkgs.follows = "nixpkgs";
      };
    };
    # Support splitting flake into subflakes
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs-lib";
    };
    # Manage home environment with Nix
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Disk Partitioning with Nix
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Gives me a pre-computed programs.sqlite for command-not-found
    flake-programs-sqlite = {
      url = "github:wamserma/flake-programs-sqlite";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "flake-utils";
    };
    # Configure non-nixos systems with Nix modules
    system-manager = {
      url = "github:numtide/system-manager";
      inputs = {
        crane.follows = "crane";
        devshell.follows = "devshell";
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
        pre-commit-hooks.follows = "pre-commit-hooks-nix";
        rust-overlay.follows = "rust-overlay";
        treefmt-nix.follows = "treefmt-nix";
      };
    };
    mozilla-addons-to-nix = {
      url = "sourcehut:~rycee/mozilla-addons-to-nix";
      inputs = {
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
      };
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.3.0";
      inputs = {
        crane.follows = "crane";
        flake-parts.follows = "flake-parts";
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
        pre-commit-hooks-nix.follows = "pre-commit-hooks-nix";
        rust-overlay.follows = "rust-overlay";
      };
    };
    carapace = {
      url = "github:rsteube/carapace-bin";
      flake = false;
    };
    wezterm = {
      url = "https://github.com/wez/wezterm.git";
      flake = false;
      type = "git";
      submodules = true;
    };
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Art / themeing
    nixos-artwork = {
      url = "github:NixOS/nixos-artwork";
      flake = false;
    };
    catppuccin-gitui = {
      url = "github:catppuccin/gitui";
      flake = false;
    };
    catppuccin-starship = {
      url = "github:catppuccin/starship";
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
      pkgs = import inputs.nixpkgs { };
    in
    flake-parts.lib.mkFlake
      {
        inherit inputs;
        specialArgs = {
          flakeloc = import ./.flakepath;
          bp = pkg: "${pkg.outPath}/bin/" + (pkg.meta.mainProgram or pkg.pname);
        };
      }
      {
        imports = [
          inputs.flake-parts.flakeModules.easyOverlay
          ./hosts/nub/flake-module.nix
          ./hosts/nixos/flake-module.nix
          ./hosts/shitbox/flake-module.nix
          ./hosts/wsl/flake-module.nix
          ./hosts/rpi4/flake-module.nix
          ./installer-rpi/flake-module.nix
          ./lillecarl/flake-module.nix
          ./modules/flake-module.nix
          ./nixos-installer/flake-module.nix
          ./repoenv/flake-module.nix
          ./system-manager/flake-module.nix
          ./terraform/flake-module.nix
        ];
        systems = [ "x86_64-linux" "x86_64-darwin" ];
        flake = { };
        perSystem =
          { config
          , system
          , pkgs
          , inputs'
          , ...
          }:
          let
            pkgs_overlaid = pkgs.extend (import ./pkgs);
            own_pkgs = import ./pkgs/pkgs.nix pkgs_overlaid pkgs_overlaid true;
          in
          {
            formatter = pkgs.nixpkgs-fmt;
            packages = own_pkgs // {
              gitbutler = pkgs.callPackage ./pkgs/gitbutler {
                rustPlatform = pkgs.makeRustPlatform {
                  rustc = inputs.fenix.packages.${system}.default.toolchain;
                  cargo = inputs.fenix.packages.${system}.default.toolchain;
                };
              };
              hyprpy = pkgs.python3Packages.callPackage ./pkgs/python3Packages/hyprpy { };
              pkgtest = pkgs.python3Packages.callPackage ./pkgs/python3Packages/pybintest { };
            };
            legacyPackages = pkgs_overlaid;
          };
      };
}
