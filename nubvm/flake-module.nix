{ inputs, lib, ... }:
{
  flake = {
    nixosConfigurations.nub = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./default
        ../common/verycommon.nix
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
}
