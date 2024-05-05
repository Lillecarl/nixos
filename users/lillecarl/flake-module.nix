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
        workstation = excludeName:
          withSystem system ({ pkgs, mpkgs, spkgs, flakeloc, ... }:
            inputs.home-manager.lib.homeManagerConfiguration {
              inherit pkgs;
              extraSpecialArgs =
                {
                  inherit self inputs flakeloc mpkgs spkgs;
                  nixosConfig = self.nixosConfigurations.shitbox.config;
                };
              modules = pkgs.lib.rimport {
                path = [ ./. ../_shared ../../modules/hm ];
                regdel = [ __curPos.file ".*${excludeName}.*" ];
              };
            });
      in
      {
        "lillecarl@shitbox" = workstation "nub";
        "lillecarl@nub" = workstation "shitbox";
      };
  };
}
