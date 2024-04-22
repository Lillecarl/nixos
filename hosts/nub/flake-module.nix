{ self
, inputs
, withSystem
, __curPos ? __curPos
, ...
}@top:
let
  system = "x86_64-linux";
in
{
  flake = {
    nixosConfigurations.nub =
      withSystem system ({ config, pkgs, flakeloc, flakepath, ... }@ctx:
        inputs.nixpkgs.lib.nixosSystem {
          inherit pkgs;
          modules = ([
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
          ]
          ++ pkgs.lib.umport3 { path = ../_shared; }
          ++ pkgs.lib.umport3 { path = ./.; regdel = __curPos.file; }
          );

          specialArgs = {
            inherit inputs flakeloc flakepath self;
          };
        });
  };
}
