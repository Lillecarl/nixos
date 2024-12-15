{
  self,
  inputs,
  withSystem,
  #, flakeloc
  __curPos ? __curPos,
  ...
}:
{
  flake = {
    homeConfigurations =
      let
        workstation =
          sysName: excludeName: config:
          withSystem "x86_64-linux" (
            {
              pkgs,
              mpkgs,
              spkgs,
              flakeloc,
              ...
            }:
            inputs.home-manager.lib.homeManagerConfiguration {
              inherit pkgs;
              extraSpecialArgs = {
                inherit
                  self
                  inputs
                  flakeloc
                  mpkgs
                  spkgs
                  ;
                nixosConfig = self.nixosConfigurations.${sysName}.config;
              };
              modules =
                pkgs.lib.rimport {
                  path = [
                    ./.
                    ../_shared
                    ../../modules/hm
                  ];
                  regdel = [
                    __curPos.file
                    ".*${excludeName}.*"
                  ];
                }
                ++ [ config ];
            }
          );
      in
      {
        "lillecarl@shitbox" = workstation "shitbox" "nub" {
          carl.gui.enable = true;
        };
        "lillecarl@nub" = workstation "nub" "shitbox" {
          carl.gui.enable = true;
        };
        "lillecarl@penguin" = withSystem "aarch64-linux" (
          {
            pkgs,
            mpkgs,
            spkgs,
            flakeloc,
            ...
          }:
          inputs.home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            extraSpecialArgs = {
              inherit
                self
                inputs
                flakeloc
                mpkgs
                spkgs
                ;
            };
            modules = [
              ../lillecarl
              {
                ps.terminal.nerdfonts = false;
                ps.hostname = "penguin";
                ps.editors.mode = "fat";
                ps.podman.enable = true;
              }
            ];
          }
        );
        "lillecarl@hetzner1" = withSystem "aarch64-linux" (
          {
            pkgs,
            mpkgs,
            spkgs,
            flakeloc,
            ...
          }:
          inputs.home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            extraSpecialArgs = {
              inherit
                self
                inputs
                flakeloc
                mpkgs
                spkgs
                ;
              nixosConfig = self.nixosConfigurations.hetzner1;
            };
            modules = [
              ../lillecarl
              {
                ps.terminal.nerdfonts = false;
                ps.hostname = "penguin";
                ps.editors.mode = "fat";
                ps.podman.enable = false;
              }
            ];
          }
        );
      };
  };
}
