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
          ../common/overlays.nix
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
            monitorConfig = ''
              monitor=DP-1,2560x1440@164.802002,1080x240,1.0
              monitor=DP-2,1920x1080@143.996002,0x0,1.0
              monitor=DP-2,transform,3
              monitor=DP-3,1920x1080@143.996002,3640x0,1.0
              monitor=DP-3,transform,1
            '';
            systemConfig = self.nixosConfigurations.shitbox.config;
          };
        });
        "lillecarl@nub" = mkHome "x86_64-linux" (guibase // {
          modules = guibase.modules ++ [
            ./gui/batmon.nix
          ];
          extraSpecialArgs = {
            keyboardName = "at-translated-set-2-keyboard";
            bluetooth = true;
            monitorConfig = ''
              monitor=DP-2,3440x1440@60,0x0,1.0
              monitor=eDP-1,1920x1200@60,760x1440,1.0
            '';
            systemConfig = self.nixosConfigurations.nub.config;
          };
        });
        "lillecarl@wsl" = mkHome "x86_64-linux" {
          extraSpecialArgs = { };
          modules = [
            ./terminal
          ];
        };
        lillecarl-term = mkHome "x86_64-linux" {
          extraSpecialArgs = { };
          modules = [
            ./terminal
          ];
        };
      };
  };
}
