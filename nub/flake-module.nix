{ inputs
, lib
, ...
}: {
  flake = rec {
    nixosConfigurations.nub = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./default.nix
        ../common
        ../common/users.nix
        ../common/flatpak.nix
        ../common/verycommon.nix
        ../common/xplatform.nix
        ../modules/nixos/ifupdown2
        inputs.disko.nixosModules.disko
        inputs.dwarffs.nixosModules.dwarffs
        inputs.nixos-hardware.nixosModules.common-pc-laptop-acpi_call
        inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
        inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen3
        (
          { config, ... }:
          {
            disko.devices = (import ./disko.nix { }).disko.devices;
          }
        )
      ];
      specialArgs = {
        inherit inputs;
        programs-sqlite-db = inputs.flake-programs-sqlite.packages."x86_64-linux".programs-sqlite;
      };
    };
  };
}
