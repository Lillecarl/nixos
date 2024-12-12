{
  self,
  inputs,
  withSystem,
  ...
}:
let
  system = "aarch64-linux";
in
{
  flake = {
    homeConfigurations = {
      "lillecarl@penguin" = withSystem system (
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
    };
  };
}
