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
      url = github:nix-community/home-manager;
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "flake-utils";
    };
    # Configure KDE user settings with Nix
    plasma-manager = {
      url = github:pjones/plasma-manager;
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
  };

  outputs = { self, flake-parts, ... } @inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.flake-parts.flakeModules.easyOverlay
        ./lillecarl/flake-module.nix
      ];
      systems = [ "x86_64-linux" "x86_64-darwin" ];
      flake = rec {
        nixosConfigurations = rec {
          shitbox = inputs.nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              ./shitbox
              ./common
              ./common/flatpak.nix
              ./common/verycommon.nix
              ./common/keybindings.nix
              ./common/killservice.nix
              inputs.disko.nixosModules.disko
              inputs.nixos-hardware.nixosModules.common-gpu-nvidia-disable
              inputs.nixos-hardware.nixosModules.common-cpu-amd
              inputs.nixos-hardware.nixosModules.common-pc-ssd
              inputs.nixos-hardware.nixosModules.common-pc
            ];
            specialArgs = {
              inherit inputs;
              programs-sqlite-db = inputs.flake-programs-sqlite.packages."x86_64-linux".programs-sqlite;
            };
          };
          nub = inputs.nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              ./nub
              ./common
              ./common/flatpak.nix
              ./common/verycommon.nix
              ./common/keybindings.nix
              ./common/killservice.nix
              ./common/xplatform.nix
              ./modules/ifupdown2
              inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t14s
              inputs.nixos-hardware.nixosModules.common-cpu-amd
              inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
              inputs.nixos-hardware.nixosModules.common-gpu-amd
              inputs.nixos-hardware.nixosModules.common-pc-laptop
              inputs.nixos-hardware.nixosModules.common-pc-laptop-acpi_call
              inputs.nixos-hardware.nixosModules.common-pc-ssd
              inputs.nixos-hardware.nixosModules.common-pc
              inputs.dwarffs.nixosModules.dwarffs
            ];
            specialArgs = {
              inherit inputs;
              programs-sqlite-db = inputs.flake-programs-sqlite.packages."x86_64-linux".programs-sqlite;
            };
          };
          nubvm = inputs.nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              ./nubvm
              ./common/verycommon.nix
              inputs.disko.nixosModules.disko
              inputs.nixos-hardware.nixosModules.common-pc-ssd
              inputs.nixos-hardware.nixosModules.common-pc
            ];
            specialArgs = {
              inherit inputs;
              programs-sqlite-db = inputs.flake-programs-sqlite.packages."x86_64-linux".programs-sqlite;
            };
          };
        };
      };
      perSystem = { config, system, pkgs, inputs', ... }:
        let
          pkgs_overlaid = (pkgs.extend (import ./pkgs));
          own_pkgs = (import ./pkgs/pkgs.nix pkgs_overlaid pkgs_overlaid true);
        in
        {
          formatter = pkgs.nixpkgs-fmt;
          packages = own_pkgs;
          legacyPackages = pkgs_overlaid;
          devShells.default = (pkgs_overlaid.buildFHSUserEnv rec {
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
