{ inputs
, lib
, ...
}: {
  flake = {
    nixosConfigurations.nixos-installer = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./default.nix
        "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-plasma5-new-kernel.nix"
      ];
      specialArgs = {
        inherit inputs;
        programs-sqlite-db = inputs.flake-programs-sqlite.packages."x86_64-linux".programs-sqlite;
      };
    };
  };
}
