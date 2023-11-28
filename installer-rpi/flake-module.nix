{ inputs
, lib
, ...
}: {
  flake = rec {
    nixosConfigurations.installer-rpi4 = inputs.nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        ./default.nix
        "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-raspberrypi.nix"
        inputs.nixos-hardware.nixosModules.raspberry-pi-4
      ];
      specialArgs = {
        inherit inputs;
        programs-sqlite-db = inputs.flake-programs-sqlite.packages."x86_64-linux".programs-sqlite;
      };
    };
    images.rpi4 = nixosConfigurations.installer-rpi4.config.system.build.sdImage;
  };
}