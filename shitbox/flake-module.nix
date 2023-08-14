{ inputs
, lib
, ...
}: {
  flake = {
    nixosConfigurations.shitbox = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./default.nix
        ../common
        ../common/flatpak.nix
        ../common/verycommon.nix
        inputs.disko.nixosModules.disko
        inputs.nixos-hardware.nixosModules.common-gpu-nvidia-disable
        inputs.nixos-hardware.nixosModules.common-cpu-amd
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
