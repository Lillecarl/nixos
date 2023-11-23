{ inputs
, lib
, flakeloc
, ...
}: {
  flake = {
    nixosConfigurations.wsl = inputs.nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        ../../common/fish.nix
        ../../common/overlays.nix
        ../../common/verycommon.nix
        ../../common/users.nix
        ../../common/nix.nix
        ./cachix.nix
        ./configuration.nix
        inputs.nixos-wsl.nixosModules.wsl
        inputs.nixos-hardware.nixosModules.raspberry-pi-4
      ];
      specialArgs = {
        inherit inputs flakeloc;
        programs-sqlite-db = inputs.flake-programs-sqlite.packages."x86_64-linux".programs-sqlite;
      };
    };
  };
}
