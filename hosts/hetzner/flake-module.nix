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
  flake =
    let
      hostname = "hetzner1";
    in
    {
      nixosConfigurations.${hostname} = withSystem system (
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
              networking.hostName = hostname;
              networking.firewall.enable = false;
              services.openssh.enable = true;
              programs.git.enable = true;
              environment.systemPackages = [
                pkgs.gitui
              ];
            }
            ./default.nix
          ];
          inherit specialArgs;
        }
      );
      deploy.nodes.${hostname} = {
        hostname = "65.21.63.133";
        profiles.system = {
          user = "root";
          sshUser = "root";
          path = inputs.deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.${hostname};
        };
      };

      # This is highly advised, and will prevent many possible mistakes
      # checks = builtins.mapAttrs (
      #   system: deployLib: deployLib.deployChecks self.deploy
      # ) inputs.deploy-rs.lib;
    };
}
