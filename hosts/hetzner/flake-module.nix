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
    nixosConfigurations = builtins.mapAttrs (
      name: data:
      withSystem system (
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
              networking.hostName = name;
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
      )
    ) (builtins.fromJSON (builtins.readFile ./hosts.json));

    deploy.nodes = builtins.mapAttrs (name: data: {
      hostname = data.ipv4_address;
      profiles.system = {
        user = "root";
        sshUser = "root";
        path = inputs.deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.${name};
      };
    }) (builtins.fromJSON (builtins.readFile ./hosts.json));

    # This is highly advised, and will prevent many possible mistakes
    # checks = builtins.mapAttrs (
    #   system: deployLib: deployLib.deployChecks self.deploy
    # ) inputs.deploy-rs.lib;
  };
}
