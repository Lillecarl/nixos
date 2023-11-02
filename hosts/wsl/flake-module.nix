{ inputs
, lib
, ...
}: {
  flake = {
    nixosConfigurations.wsl = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ../../common/fish.nix
        ../../common/overlays.nix
        ../../common/users.nix
        ./cachix.nix
        ./configuration.nix
	inputs.nixos-wsl.nixosModules.wsl
      ];
      specialArgs = {
        inherit inputs;
        programs-sqlite-db = inputs.flake-programs-sqlite.packages."x86_64-linux".programs-sqlite;
      };
    };
  };
}
