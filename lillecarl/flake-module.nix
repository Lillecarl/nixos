{ self
, inputs
, withSystem
, flakeloc
, bp
, ...
}:
let
  mkHome = system: customArgs:
    withSystem system ({ pkgs, ... }:
      inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = pkgs // { config.allowUnfree = true; };
        extraSpecialArgs =
          {
            inherit self inputs flakeloc bp;
          } // customArgs.extraSpecialArgs;
        modules = [
          inputs.stylix.homeManagerModules.stylix
          "${self}/common/overlays.nix"
          "${self}/common/stylix.nix"
          "${self}/modules/hm/keymapper.nix"
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
            inputs.nix-flatpak.homeManagerModules.nix-flatpak
          ];
        };
      in
      {
        "lillecarl@shitbox" = mkHome "x86_64-linux" (guibase // {
          extraSpecialArgs = {
            keyboardName = "keymapper";
            bluetooth = false;
            monitorConfig = ''
              monitor=DP-1,2560x1440@164.802002,1080x240,1.0
              monitor=DP-2,1920x1080@143.996002,0x0,1.0
              monitor=DP-2,transform,3
              monitor=DP-3,1920x1080@143.996002,3640x0,1.0
              monitor=DP-3,transform,1
            '';
            systemConfig = self.nixosConfigurations.shitbox.config;
            nixosConfig = self.nixosConfigurations.shitbox.config;
          };
        });
        "lillecarl@nub" = mkHome "x86_64-linux" (guibase // {
          modules = guibase.modules ++ [
            ./gui/batmon.nix
          ];
          extraSpecialArgs = {
            keyboardName = "keymapper";
            bluetooth = true;
            monitorConfig = ''
              # Work external display
              monitor=DP-1,3440x1440@60,0x0,1.0
              # Home external display
              monitor=HDMI-A-1,2560x1440@144,0x0,1.0
              # Laptop integrated display
              monitor=eDP-1,1920x1200@60,760x1440,1.0
            '';
            systemConfig = self.nixosConfigurations.nub.config;
            nixosConfig = self.nixosConfigurations.nub.config;
          };
        });
        "lillecarl@wsl" = mkHome "x86_64-linux" {
          extraSpecialArgs = { };
          modules = [
            ./terminal
          ];
        };
        "lillecarl@pi" = mkHome "aarch64-linux" {
          extraSpecialArgs = {
            systemConfig = self.nixosConfigurations.pi.config;
            nixosConfig = self.nixosConfigurations.pi.config;
          };
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
