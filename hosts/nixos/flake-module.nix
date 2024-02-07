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
        {
          imports = [ "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix" ];
          nix = {
            extraOptions = ''
              experimental-features = nix-command flakes repl-flake
              builders-use-substitutes = true
              keep-outputs = true
              keep-derivations = true
            '';
            settings = {
              auto-optimise-store = true;
              trusted-users = [ "root" "@wheel" ];

              trusted-public-keys = [
                "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
              ];
              substituters = [
                "https://cache.nixos.org"
              ];
            };
          };
        }
      ];
      specialArgs = {
        inherit inputs flakeloc bp self;
      };
    };
  };
}
