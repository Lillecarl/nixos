{ inputs
, self
, flakeloc
, bp
, modulesPath
, ...
}:
let
  system = "x86_64-linux";
in
{
  flake = {
    nixosConfigurations.nixos = inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ./disko.nix
        ./configuration.nix
        ./hardware-configuration.nix
        "${self}/common/default.nix"
        "${self}/common/users.nix"
        "${self}/common/verycommon.nix"
        "${self}/common/nix.nix"
        inputs.disko.nixosModules.disko
      ];
      specialArgs = {
        inherit inputs flakeloc bp self;
      };
    };
  };
}
