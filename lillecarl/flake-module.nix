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
        pkgs =
          pkgs
          // {
            config.allowUnfree = true;
          };
        extraSpecialArgs =
          {
            inherit self;
            inherit inputs;
            flakeloc = builtins.readFile ../.flakepath;
          }
          // customArgs.extraSpecialArgs;
        modules = with self.homeModules; [ ] ++ customArgs.modules;
      });

in
{
  flake = {
    homeConfigurations = rec {
      lillecarl-gui = mkHome "x86_64-linux" {
        extraSpecialArgs = { };
        modules = [
          ./gui
          ./terminal
          ./default.nix
          inputs.nur.nixosModules.nur
          inputs.hyprland.homeManagerModules.default
        ];
      };
      "lillecarl@shitbox" = lillecarl-gui;
      "lillecarl@nub" = lillecarl-gui;
      lillecarl-term = mkHome "x86_64-linux" {
        extraSpecialArgs = { };
        modules = [
          ./terminal
          ./default.nix
        ];
      };
    };
  };
}
