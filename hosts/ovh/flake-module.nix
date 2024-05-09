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
    nixosConfigurations.ovh =
      withSystem system ({ pkgs, flakeloc, ... }@ctx:
        inputs.nixpkgs.lib.nixosSystem {
          inherit pkgs;
          modules = [
            inputs.disko.nixosModules.disko
            ./configuration.nix
            ./disko.nix
            ./hardware-configuration.nix
          ];
          specialArgs = {
            inherit inputs flakeloc self;
          };
        });
  };
}

