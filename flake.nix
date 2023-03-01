{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
    nixpkgs-stable.url = github:NixOS/nixpkgs/nixos-22.11;
    nixos-hardware.url = github:NixOS/nixos-hardware/master;
    nixpkgs-wayland = {
      url = "github:nix-community/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs-channel.url = "https://nixos.org/channels/nixos-unstable/nixexprs.tar.xz";
    dwarffs = {
      url = "github:edolstra/dwarffs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = github:nix-community/home-manager;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = github:pjones/plasma-manager;
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
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
              inputs.nixos-hardware.nixosModules.common-cpu-amd
              inputs.nixos-hardware.nixosModules.common-pc-ssd
              inputs.nixos-hardware.nixosModules.common-pc
            ];
            specialArgs = { inherit inputs; };
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
            specialArgs = { inherit inputs; };
          };
          nubvm = inputs.nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              ./nubvm
              ./common/verycommon.nix
              inputs.nixos-hardware.nixosModules.common-pc-ssd
              inputs.nixos-hardware.nixosModules.common-pc
            ];
            specialArgs = { inherit inputs; };
          };
        };
      };
      perSystem = { config, system, pkgs, inputs', ... }:
        let
          pkgs_overlaid = (pkgs.extend (import ./pkgs));
        in
        {
          formatter = pkgs.nixpkgs-fmt;
          packages = (import ./pkgs pkgs pkgs_overlaid);
          legacyPackages = (import ./pkgs pkgs pkgs_overlaid);
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
