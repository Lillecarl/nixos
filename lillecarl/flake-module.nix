{ self
, inputs
, withSystem
, nixpkgs-unfree
, ...
}:
let
  mkHome = system: customArgs:
    withSystem system ({ pkgs, ... }:
      inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = (pkgs // { config.allowUnfree = true; });
        extraSpecialArgs = {
          inherit self;
          inherit inputs;
        }
        // customArgs.extraSpecialArgs;
        modules = with self.homeModules; [ ] ++ customArgs.modules;
      });
in
{
  flake = {
    homeConfigurations = {
      lillecarl-gui = mkHome "x86_64-linux" {
        extraSpecialArgs = { };
        modules = [
          ./gui.nix
          ./terminal.nix
          ./default.nix
          inputs.plasma-manager.homeManagerModules.plasma-manager
        ];
      };
      lillecarl-term = mkHome "x86_64-linux" {
        extraSpecialArgs = { };
        modules = [
          ./terminal.nix
          ./default.nix
          inputs.plasma-manager.homeManagerModules.plasma-manager
        ];
      };
    };
  };
}
