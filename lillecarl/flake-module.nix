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
        pkgs = pkgs // { config.allowUnfree = true; };
        extraSpecialArgs =
          {
            inherit self;
            inherit inputs;
            inherit flakeloc;
          } // customArgs.extraSpecialArgs;
        modules = [
          ./default.nix
        ] ++ customArgs.modules;
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
            inputs.hyprland.homeManagerModules.default
          ];
        };
      in
      {
        "lillecarl@shitbox" = mkHome "x86_64-linux" (guibase // {
          extraSpecialArgs = {
            keyboardName = "daskeyboard";
            bluetooth = false;
          };
        });
        "lillecarl@nub" = mkHome "x86_64-linux" (guibase // {
          extraSpecialArgs = {
            keyboardName = "at-translated-set-2-keyboard";
            bluetooth = true;
          };
        });
        lillecarl-term = mkHome "x86_64-linux" {
          extraSpecialArgs = { };
          modules = [
            ./terminal
          ];
        };
      };
  };
}
