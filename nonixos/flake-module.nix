{ inputs
, lib
, ...
}: {
  flake = {
    nixosConfigurations.nonixos = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./default.nix
      ];
      specialArgs = { inherit inputs; };
    };
  };
}
