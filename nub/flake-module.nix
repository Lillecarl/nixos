{ inputs
, ...
}:
let
  system = "x86_64-linux";
in
{
  flake = {
    nixosConfigurations.nub = inputs.nixpkgs.lib.nixosSystem {
      system = system;
      modules = [
        ../common
        ../common/fish.nix
        ../common/openvpn.nix
        ../common/flatpak.nix
        ../common/greetd.nix
        ../common/hyprland.nix
        ../common/nix.nix
        ../common/thinkpad.nix
        ../common/users.nix
        ../common/verycommon.nix
        ../common/xdg.nix
        ../common/xplatform.nix
        ./default.nix
        ./tlp.nix
        inputs.disko.nixosModules.disko
        inputs.dwarffs.nixosModules.dwarffs
        inputs.hyprland.nixosModules.default
        inputs.lanzaboote.nixosModules.lanzaboote
        inputs.nixos-hardware.nixosModules.common-pc-laptop-acpi_call
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
        programs-sqlite-db = inputs.flake-programs-sqlite.packages.${system}.programs-sqlite;
      };
    };
  };
}
