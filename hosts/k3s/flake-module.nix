{
  self,
  inputs,
  withSystem,
  __curPos ? __curPos,
  ...
}:
let
  system = "aarch64-linux";
  # system = "x86_64-linux";
in
{
  flake = {
    nixosConfigurations.k3s1 = withSystem system (
      {
        config,
        pkgs,
        flakeloc,
        ...
      }:
      let
        specialArgs = {
          inherit inputs flakeloc self;
        };
      in
      inputs.nixpkgs.lib.nixosSystem {
        inherit pkgs;
        modules = [
          ./default.nix
        ];
        inherit specialArgs;
      }
    );
    deploy.nodes.k3s1 = withSystem system (
      { pkgs, ... }:
      let
        deployPkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [
            inputs.deploy-rs.overlays.default
            (self: super: {
              deploy-rs = {
                inherit (pkgs) deploy-rs;
                lib = super.deploy-rs.lib;
              };
            })
          ];
        };
      in
      {
        hostname = "46.62.143.208";
        profiles.system = {
          user = "root";
          sshUser = "root";
          path = deployPkgs.deploy-rs.lib.activate.nixos self.nixosConfigurations.k3s1;
        };
      }
    );
  };
}
