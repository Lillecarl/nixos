{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
    nixos-hardware.url = github:NixOS/nixos-hardware/master;
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
        ./lillecarl/flake-module.nix
      ];
      systems = [ "x86_64-linux" "x86_64-darwin" ];
      flake = {
        nixosConfigurations = rec {
          shitbox = inputs.nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              ./shitbox
              ./common
              ./common/flatpak.nix
              ./common/keybindings.nix
              ./common/killservice.nix
              inputs.nixos-hardware.nixosModules.common-cpu-amd
              inputs.nixos-hardware.nixosModules.common-pc-ssd
              inputs.nixos-hardware.nixosModules.common-pc

              inputs.home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.backupFileExtension = "old"; # Move non-hm files if they're in the way
                home-manager.users.lillecarl = import ./lillecarl;
                home-manager.sharedModules = [ inputs.plasma-manager.homeManagerModules.plasma-manager ];
              }
            ];
            specialArgs = { inherit inputs; };
          };
          nub = inputs.nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              ./nub
              ./common
              ./common/flatpak.nix
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

              inputs.home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.backupFileExtension = "old"; # Move non-hm files if they're in the way
                home-manager.users.lillecarl = import ./lillecarl;

                home-manager.sharedModules = [ inputs.plasma-manager.homeManagerModules.plasma-manager ];
              }
            ];
            specialArgs = { inherit inputs; };
          };
        };
      };
      perSystem = { config, system, pkgs, ... }: {
        formatter = pkgs.nixpkgs-fmt;
        packages = {
          acme-dns = pkgs.callPackage ./pkgs/acme-dns { };
          pajv = (pkgs.callPackage ./pkgs/node-packages { }).pajv;
        };
      };
    };
}
