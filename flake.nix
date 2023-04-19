{
  inputs = {
    # nixos branch, calling it nixpkgs because that's the default everyone uses.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-lib.url = "github:NixOS/nixpkgs/nixos-unstable?dir=lib";
    nix-community-lib.url = "github:nix-community/nixpkgs.lib/master";
    nix-eval-jobs = {
      url = "github:nix-community/nix-eval-jobs/main";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };
    lib-aggregate = {
      url = "github:nix-community/lib-aggregate/master";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs-lib.follows = "nix-community-lib";
    };
    # Stable nixpkgs, when packages are broken in unstable this is useful
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-22.11";
    # NixOS hardware configuration modules/library
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    # Use Nix as Terraform
    terranix = {
      url = "github:terranix/terranix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    # Wayland packages for NixOS
    nixpkgs-wayland = {
      url = "github:nix-community/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nix-eval-jobs.follows = "nix-eval-jobs";
      inputs.lib-aggregate.follows = "lib-aggregate";
    };
    # Current unused, provides flake helpers
    flake-utils.url = "github:numtide/flake-utils";
    # Support splitting flake into subflakes
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs-lib";
    };
    # Supposed to moutn and download debug files on the fly
    dwarffs = {
      url = "github:edolstra/dwarffs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Manage home environment with Nix
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Configure KDE user settings with Nix
    plasma-manager = {
      url = "github:pjones/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
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
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    mozilla-addons-to-nix = {
      url = "sourcehut:~rycee/mozilla-addons-to-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    nil = {
      url = "github:oxalica/nil";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    nur.url = "github:nix-community/NUR";
  };

  outputs =
    { self
    , flake-parts
    , ...
    } @ inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.flake-parts.flakeModules.easyOverlay
        ./lillecarl/flake-module.nix
        ./modules/flake-module.nix
        ./nonixos/flake-module.nix
        ./nub/flake-module.nix
        ./nubvm/flake-module.nix
        ./shitbox/flake-module.nix
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
          packages = own_pkgs;
          legacyPackages = pkgs_overlaid;
          devShells.default =
            (pkgs_overlaid.buildFHSUserEnv rec {
              name = "testuserenv";

              targetPkgs = pkgs: (with pkgs_overlaid; [
                xonsh
                apt
              ]);

              multiPkgs = targetPkgs;

              runScript = "bash";
            }).env;
        };
    };
}
