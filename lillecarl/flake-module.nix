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
        pkgs = (pkgs // {
          config.allowUnfree = true; 
          config.permittedInsecurePackages = [
            "electron-21.4.0"
          ];
        });
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
          ./gui
          ./terminal
          ./default.nix
          inputs.nur.nixosModules.nur
          inputs.plasma-manager.homeManagerModules.plasma-manager
        ];
      };
      lillecarl-term = mkHome "x86_64-linux" {
        extraSpecialArgs = { };
        modules = [
          ./terminal
          ./default
        ];
      };
    };
  };
}
