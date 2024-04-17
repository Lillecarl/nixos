{ self
, inputs
, withSystem
, ...
}@top:
let
  system = "x86_64-linux";
in
{
  flake = {
    nixosConfigurations.nub =
      withSystem system ({ pkgs, flakeloc, ... }@ctx:
        inputs.nixpkgs.lib.nixosSystem {
          inherit pkgs;
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
            inputs.niri.nixosModules.niri
            inputs.nixos-hardware.nixosModules.common-pc-laptop-acpi_call
            inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen3
            inputs.stylix.nixosModules.stylix
            {
              programs.niri.enable = true;
            }
          ];
          specialArgs = {
            inherit inputs flakeloc self;
          };
        });
  };
}
