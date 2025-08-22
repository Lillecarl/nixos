{
  self,
  inputs,
  withSystem,
  __curPos ? __curPos,
  ...
}:
let
  system = "x86_64-linux";
in
{
  flake.nixosConfigurations.linvidia = withSystem system (
    {
      pkgs,
      ...
    }:
    let
      specialArgs = {
        inherit inputs self;
      };
    in
    inputs.nixpkgs.lib.nixosSystem {
      inherit pkgs;
      modules = [
        ./default.nix
      ];
      inherit specialArgs;
    }
  );
}
