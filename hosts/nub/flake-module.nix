{ inputs
, flakeloc
, bp
, ...
}:
let
  system = "x86_64-linux";
in
{
  flake = {
    nixosConfigurations.nub = inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ../../common
        ../../common/acme.nix
        ../../common/btrfs.nix
        ../../common/fish.nix
        ../../common/flatpak.nix
        ../../common/greetd.nix
        ../../common/hyprland.nix
        ../../common/keymapper.nix
        ../../common/monitoring.nix
        ../../common/nix.nix
        ../../common/openvpn.nix
        ../../common/overlays.nix
        ../../common/plymouth.nix
        ../../common/stylix.nix
        ../../common/thinkpad.nix
        ../../common/users.nix
        ../../common/verycommon.nix
        ../../common/xdg.nix
        ../../common/xplatform.nix
        ../../modules/nixos/keymapper.nix
        ./default.nix
        inputs.disko.nixosModules.disko
        inputs.flake-programs-sqlite.nixosModules.programs-sqlite
        inputs.lanzaboote.nixosModules.lanzaboote
        inputs.nixos-hardware.nixosModules.common-pc-laptop-acpi_call
        inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen3
        inputs.stylix.nixosModules.stylix
      ];
      specialArgs = {
        inherit inputs flakeloc bp;
      };
    };
  };
}
