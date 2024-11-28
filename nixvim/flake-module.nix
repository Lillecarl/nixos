{ self
, inputs
, __curPos ? __curPos
, ...
}:
{
  perSystem = { system, pkgs, ... }:
    {
      packages.nixvim = inputs.nixvim.legacyPackages.${pkgs.system}.makeNixvimWithModule {
        inherit pkgs;
        module = {
          imports = [
            ./default.nix
          ];
          config = {
            # Standalone specific config
          };
        };
        extraSpecialArgs = {
          inherit inputs;
        };
      };
    };
}
