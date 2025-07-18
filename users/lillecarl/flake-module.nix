{
  self,
  inputs,
  withSystem,
  #, repositoryLocation
  __curPos ? __curPos,
  ...
}:
let
  lib = inputs.nixpkgs-lib.lib;
in
{
  flake = {
    homeConfigurations =
      (
        let
          workstation =
            sysName: excludeName: config:
            withSystem "x86_64-linux" (
              {
                pkgs,
                mpkgs,
                spkgs,
                repositoryLocation,
                ...
              }:
              inputs.home-manager.lib.homeManagerConfiguration {
                inherit pkgs;
                extraSpecialArgs = {
                  inherit
                    self
                    inputs
                    repositoryLocation
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
                    ];
                    regdel = [
                      __curPos.file
                      ".*${excludeName}.*"
                    ];
                  }
                  ++ [ config ]
                  ++ [
                    ../lillecarl
                    {
                      ps.terminal.nerdfonts = true;
                      ps.hostname = "shitbox";
                      ps.terminal.mode = "fat";
                      ps.editors.mode = "fat";
                      ps.podman.enable = false;
                      ps.gui.enable = true;
                    }
                  ];
              }
            );
        in
        {
          "lillecarl@shitbox" = workstation "shitbox" "nub" {
            # module code
          };
          "lillecarl@nub" = workstation "nub" "shitbox" {
            # module code
          };
          "lillecarl@penguin" = withSystem "aarch64-linux" (
            {
              pkgs,
              mpkgs,
              spkgs,
              repositoryLocation,
              ...
            }:
            inputs.home-manager.lib.homeManagerConfiguration {
              inherit pkgs;
              extraSpecialArgs = {
                inherit
                  self
                  inputs
                  repositoryLocation
                  mpkgs
                  spkgs
                  ;
              };
              modules = [
                ../lillecarl
                {
                  ps.terminal.nerdfonts = false;
                  ps.hostname = "penguin";
                  ps.terminal.mode = "slim";
                  ps.editors.mode = "slim";
                  ps.podman.enable = false;
                  # thrash eMMC disk less
                  nix.settings.auto-optimise-store = false;
                }
              ];
            }
          );
        }
      )
      // lib.mapAttrs' (name: data: {
        name = "lillecarl@${name}";
        value = withSystem data.labels.arch (
          {
            pkgs,
            mpkgs,
            spkgs,
            repositoryLocation,
            ...
          }:
          inputs.home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            extraSpecialArgs = {
              inherit
                self
                inputs
                repositoryLocation
                mpkgs
                spkgs
                ;
              nixosConfig = self.nixosConfigurations.${name}.config;
            };
            modules = [
              ../lillecarl
              {
                ps.terminal.nerdfonts = false;
                ps.hostname = name;
                ps.terminal.mode = "fat";
                ps.editors.mode = "fat";
                ps.podman.enable = false;
                ps.awscli.enable = false; # broken atm
              }
            ];
          }
        );
      }) (builtins.fromJSON (builtins.readFile "${self}/hosts/hetzner/hosts.json"));
  };
}
