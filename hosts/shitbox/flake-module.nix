{ inputs
, lib
, flakeloc
, ...
}: {
  flake = {
    nixosConfigurations.shitbox = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ../../common
        ../../common/fish.nix
        ../../common/flatpak.nix
        ../../common/greetd.nix
        ../../common/hyprland.nix
        ../../common/keymapper.nix
        ../../common/nix.nix
        ../../common/overlays.nix
        ../../common/users.nix
        ../../common/verycommon.nix
        ../../common/xdg.nix
        ../../modules/nixos/keymapper.nix
        ./default.nix
        inputs.disko.nixosModules.disko
        inputs.hyprland.nixosModules.default
        inputs.nixos-hardware.nixosModules.common-gpu-intel
        inputs.nixos-hardware.nixosModules.common-cpu-amd
        inputs.nixos-hardware.nixosModules.common-pc
        inputs.nixos-hardware.nixosModules.common-pc-ssd
      ];
      specialArgs = {
        inherit inputs flakeloc;
        programs-sqlite-db = inputs.flake-programs-sqlite.packages."x86_64-linux".programs-sqlite;
      };
    };
  };
}