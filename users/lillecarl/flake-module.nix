{ self
, inputs
, withSystem
  #, flakeloc
, __curPos ? __curPos
, ...
}:
let
  system = "x86_64-linux";
in
{
  flake = {
    homeConfigurations =
      let
        workstation = sysName: excludeName: config:
          withSystem system ({ pkgs, mpkgs, spkgs, flakeloc, ... }:
            inputs.home-manager.lib.homeManagerConfiguration {
              inherit pkgs;
              extraSpecialArgs =
                {
                  inherit self inputs flakeloc mpkgs spkgs;
                  nixosConfig = self.nixosConfigurations.${sysName}.config;
                };
              modules = pkgs.lib.rimport {
                path = [ ./. ../_shared ../../modules/hm ];
                regdel = [ __curPos.file ".*${excludeName}.*" ];
              } ++ [ config ];
            });
      in
      {
        "lillecarl@shitbox" = workstation "shitbox" "nub" {
          carl.gui.enable = true;
        };
        "lillecarl@nub" = workstation "nub" "shitbox" {
          carl.gui.enable = true;
        };
      };
  };
}
