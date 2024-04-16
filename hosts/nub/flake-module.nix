{ inputs
, self
, flakeloc
, pkgs
, ...
}:
let
  system = "x86_64-linux";
in
{
  flake = {
    nixosConfigurations.nub = inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      pkgs = pkgs.${system};
      modules = [
        ../../common
        ../../common/acme.nix
        ../../common/btrfs.nix
        ../../common/fish.nix
        ../../common/hyprland.nix
        ../../common/monitoring.nix
        ../../common/nix.nix
        ../../common/openvpn.nix
        ../../common/stylix.nix
        ../../common/thinkpad.nix
        ../../common/users.nix
        ../../common/verycommon.nix
        ../../common/xdg.nix
        ./acme.nix
        ./default.nix
        ./fancontrol.nix
        ./tlp.nix
        inputs.agenix.nixosModules.default
        inputs.disko.nixosModules.disko
        inputs.flake-programs-sqlite.nixosModules.programs-sqlite
        inputs.lanzaboote.nixosModules.lanzaboote
        inputs.nixos-hardware.nixosModules.common-pc-laptop-acpi_call
        inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen3
        inputs.stylix.nixosModules.stylix
        inputs.niri.nixosModules.niri
        {
          programs.niri.enable = true;
        }
      ];
      specialArgs = {
        inherit inputs flakeloc self;
      };
    };
  };
}
