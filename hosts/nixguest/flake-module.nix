{ inputs
, lib
, flakeloc
, ...
}: {
  flake = {
    nixosConfigurations.nixguest = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        inputs.disko.nixosModules.disko
        ./configuration.nix
        ./disko.nix
        ./hardware-configuration.nix
      ];
      specialArgs = {
        inherit inputs;
      };
    };
  };
}
