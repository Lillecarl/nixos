{
  inputs = {
    nixpkgs-unstable.url = github:NixOS/nixpkgs/nixos-unstable;
    nixpkgs-master.url = github:NixOS/nixpkgs/master;
    nixos-hardware.url = github:NixOS/nixos-hardware/master;
    flake-utils.url = "github:numtide/flake-utils";
    nixos-unstable-channel.url = "https://nixos.org/channels/nixos-unstable/nixexprs.tar.xz";
  };

  outputs = { self, nixpkgs-unstable, nixpkgs-master, nixos-hardware, ... } @inputs:
    let
      system = "x86_64-linux"; # I guess this works as long as all my systems are x86_64-linux

      overlay-master = final: prev: {
        master = import nixpkgs-master {
          inherit system;
          config.allowUnfree = true;
        };
      };

      overlayMagic = (
        { config, pkgs, ... }:
        {
          nixpkgs.overlays = [ overlay-master ];
        }
      );
    in
    {
      nixosConfigurations = rec {
        shitbox = nixpkgs-unstable.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./shitbox
            ./common
            ./common/flatpak.nix
            ./common/killservice.nix
            overlayMagic
            nixos-hardware.nixosModules.common-cpu-amd
            nixos-hardware.nixosModules.common-pc-ssd
            nixos-hardware.nixosModules.common-pc
          ];
        };
        nub = nixpkgs-unstable.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./nub
            ./common
            ./common/flatpak.nix
            ./common/killservice.nix
            ./common/xplatform.nix
            overlayMagic
            nixos-hardware.nixosModules.lenovo-thinkpad-t14s
            nixos-hardware.nixosModules.common-cpu-amd
            nixos-hardware.nixosModules.common-gpu-amd
            nixos-hardware.nixosModules.common-pc-laptop
            nixos-hardware.nixosModules.common-pc-laptop-acpi_call
            nixos-hardware.nixosModules.common-pc-ssd
            nixos-hardware.nixosModules.common-pc
          ];
          specialArgs = inputs;
        };
      };
      #hydraJobs."nub"."x86_64-linux" = nixosConfigurations.shitbox;
    };
}
