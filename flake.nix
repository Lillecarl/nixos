{
  inputs = {
    nixpkgs-unstable.url = github:NixOS/nixpkgs/nixos-unstable;
    nixpkgs-master.url = github:NixOS/nixpkgs/master;
    nixos-hardware.url = github:NixOS/nixos-hardware/master;
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
        { nixpkgs.overlays = [ overlay-master ]; }
      );
    in
    {
      nixosConfigurations = rec {
        shitbox = nixpkgs-unstable.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./shitbox
            overlayMagic
            nixos-hardware.nixosModules.common-cpu-intel
            nixos-hardware.nixosModules.common-pc-ssd
            nixos-hardware.nixosModules.common-pc
          ];
        };
        lemur = nixpkgs-unstable.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./lemur 
            overlayMagic
            nixos-hardware.nixosModules.common-cpu-intel
            nixos-hardware.nixosModules.common-pc-laptop
            nixos-hardware.nixosModules.common-pc-ssd
            nixos-hardware.nixosModules.common-pc
            nixos-hardware.nixosModules.system76
          ];
        };
      };
    };
}
