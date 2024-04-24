{ self
, inputs
, withSystem
  #, flakeloc
, __curPos ? __curPos
, ...
}:
{
  flake = {
    homeConfigurations =
      let
        workstation = excludeName:
          withSystem "x86_64-linux" ({ pkgs, mpkgs, spkgs, flakeloc, ... }:
            inputs.home-manager.lib.homeManagerConfiguration {
              inherit pkgs;
              extraSpecialArgs =
                {
                  inherit self inputs flakeloc mpkgs spkgs;
                  nixosConfig = self.nixosConfigurations.shitbox.config;
                };
              modules = [
                (self + "/stylix.nix")
                inputs.agenix.homeManagerModules.default
                inputs.niri.homeModules.niri
                inputs.nix-flatpak.homeManagerModules.nix-flatpak
                inputs.stylix.homeManagerModules.stylix
              ]
              ++ pkgs.lib.rimport { path = [ ./. ../modules/hm ]; regdel = [ __curPos.file ".*${excludeName}.*" ]; };
            });
      in
      {
        "lillecarl@shitbox" = workstation "nub";
        "lillecarl@nub" = workstation "shitbox";
      };
  };
}
