{ inputs
, lib
, flakeloc
, ...
}: {
  flake = {
    nixosConfigurations.ovh = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        inputs.disko.nixosModules.disko
        ../../common/fish.nix
        ../../common/overlays.nix
        ../../common/verycommon.nix
        ../../common/users.nix
        ../../common/nix.nix
        ./configuration.nix
      ];
      specialArgs = {
        inherit inputs flakeloc;
        programs-sqlite-db = inputs.flake-programs-sqlite.packages."x86_64-linux".programs-sqlite;
      };
    };
  };
}
