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
    nixosConfigurations.shitbox =
      withSystem system ({ pkgs, flakeloc, ... }@ctx:
        inputs.nixpkgs.lib.nixosSystem {
          inherit pkgs;
          modules = ([
            (self + "/stylix.nix")
            inputs.agenix.nixosModules.default
            inputs.disko.nixosModules.disko
            inputs.flake-programs-sqlite.nixosModules.programs-sqlite
            inputs.niri.nixosModules.niri
            inputs.nixos-hardware.nixosModules.common-cpu-amd
            inputs.nixos-hardware.nixosModules.common-gpu-intel
            inputs.nixos-hardware.nixosModules.common-pc
            inputs.nixos-hardware.nixosModules.common-pc-ssd
            inputs.stylix.nixosModules.stylix
            ({ pkgs, ... }: {
              programs.niri = {
                enable = true;
                package = pkgs.niri-unstable;
              };
            })
          ]
          ++ pkgs.lib.rimport { path = ../_shared; }
          ++ pkgs.lib.rimport { path = ./.; regdel = [__curPos.file ".*disko\.nix"]; }
          );
          specialArgs = {
            inherit inputs flakeloc self;
          };
        });
  };
}
