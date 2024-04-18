{ self
, inputs
, flakepath
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
          ] ++ pkgs.lib.raimport { source = ../_shared; regadd = ".*\.*.nix"; regdel = ".*shitbox.*"; };
          specialArgs = {
            inherit inputs flakeloc self;
          };
        });
  };
}
