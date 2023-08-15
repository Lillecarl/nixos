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
            config.permittedInsecurePackages = [
              "electron-21.4.0"
            ];
          };
        extraSpecialArgs =
          {
            inherit self;
            inherit inputs;
          }
          // customArgs.extraSpecialArgs;
        modules = with self.homeModules; [ ] ++ customArgs.modules;
      });

  flakeloc = builtins.readFile ../.flakepath;
in
{
  flake = {
    homeConfigurations = {
      lillecarl-gui = mkHome "x86_64-linux" {
        extraSpecialArgs = { inherit flakeloc; };
        modules = [
          ./gui
          ./terminal
          ./default.nix
          inputs.nur.nixosModules.nur
          inputs.hyprland.homeManagerModules.default
        ];
      };
      lillecarl-term = mkHome "x86_64-linux" {
        extraSpecialArgs = { inherit flakeloc; };
        modules = [
          ./terminal
          ./default.nix
        ];
      };
    };
  };
}
