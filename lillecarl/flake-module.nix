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
          inputs.agenix.homeManagerModules.default
          inputs.stylix.homeManagerModules.stylix
          "${self}/common/overlays.nix"
          "${self}/common/stylix.nix"
          "${self}/modules/hm"
          ./default.nix
          ./secrets.nix
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
            nixosConfig = self.nixosConfigurations.shitbox.config;
          };
        });
        "lillecarl@nub" = mkHome "x86_64-linux" (guibase // {
          modules = guibase.modules ++ [
            "${self}/modules/hm"
            ./gui/nub.nix
          ];
          extraSpecialArgs = {
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
