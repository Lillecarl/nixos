{ self
, inputs
, withSystem
, flakeloc
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
            inherit flakeloc;
          }
          // customArgs.extraSpecialArgs;
        modules = with self.homeModules; [ ] ++ customArgs.modules;
      });
in
{
  flake = {
    homeConfigurations =
      let
        guibase = {
          extraSpecialArgs = { };
          modules = [
            ./gui
            ./terminal
            ./default.nix
            inputs.nur.nixosModules.nur
            inputs.hyprland.homeManagerModules.default
          ];
        };
      in
      {
        lillecarl-gui = mkHome "x86_64-linux" guibase;
        "lillecarl@shitbox" = mkHome "x86_64-linux" (guibase // {
          extraSpecialArgs = {
            keyboardName = "daskeyboard";
          };
        });
        "lillecarl@nub" = mkHome "x86_64-linux" (guibase // {
          extraSpecialArgs = {
            keyboardName = "at-translated-set-2-keyboard";
          };
        });
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
