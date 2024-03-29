{ self
, inputs
, withSystem
, flakeloc
, ...
}:
let
  mkHome = system: customArgs:
    withSystem system ({ pkgs, mpkgs, spkgs, ... }:
      inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs =
          {
            inherit self inputs flakeloc mpkgs;
          } // customArgs.extraSpecialArgs;

        modules = [
          inputs.stylix.homeManagerModules.stylix
          "${self}/common/overlays.nix"
          "${self}/common/stylix.nix"
          "${self}/modules/hm"
          ./default.nix
          ./moduleOverrides.nix
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
            inputs.niri.homeModules.niri
          ];
        };
      in
      {
        "lillecarl@shitbox" = mkHome "x86_64-linux" (guibase // {
          modules = guibase.modules ++ [
            ./gui/shitbox.nix
          ];
          extraSpecialArgs = {
            bluetooth = false;
            monitorConfig = ''
              monitor=DP-1,2560x1440@164.802002,1080x240,1.0
              monitor=DP-2,1920x1080@143.996002,0x0,1.0
              monitor=DP-2,transform,3
              monitor=DP-3,1920x1080@143.996002,3640x0,1.0
              monitor=DP-3,transform,1
            '';
            nixosConfig = self.nixosConfigurations.shitbox.config;
          };
        });
        "lillecarl@nub" = mkHome "x86_64-linux" (guibase // {
          modules = guibase.modules ++ [
            "${self}/modules/hm"
            ./gui/nub.nix
          ];
          extraSpecialArgs = {
            bluetooth = true;
            monitorConfig = ''
              # Work external display
              monitor=DP-1,3440x1440@60,0x0,1.0
              # Home external display
              monitor=HDMI-A-1,2560x1440@144,0x0,1.0
              # Laptop integrated display
              monitor=eDP-1,1920x1200@60,760x1440,1.0
            '';
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
