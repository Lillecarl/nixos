{
  self,
  inputs,
  withSystem,
  __curPos ? __curPos,
  ...
}:
let
  system = "aarch64-linux";
in
{
  flake = {
    nixosConfigurations.hetzner1 = withSystem system (
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
          {
            networking.hostName = "hetzner1";
            networking.firewall.enable = false;
            services.openssh.enable = true;
          }
          ./default.nix
        ];
        inherit specialArgs;
      }
    );
    deploy.nodes.some-random-system = {
        hostname = "some-random-system";
        profiles.system = {
          user = "root";
          path = inputs.deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.hetzner1;
        };
    };

    # This is highly advised, and will prevent many possible mistakes
    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) inputs.deploy-rs.lib;
  };
}
