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
      lib = inputs.nixpkgs-lib.lib;
      filePath = ./hosts.json;
      fileData = builtins.readFile filePath;
      fileAttrs = builtins.fromJSON fileData;
      fileAttrsAnywhere = lib.mapAttrs' (
        k: v:
        lib.nameValuePair "${k}-anywhere" (
          v
          // {
            labels = v.labels // {
              anywhere = "yes";
            };
          }
        )
      ) fileAttrs;
      fileAttrsMerged = fileAttrs // fileAttrsAnywhere;
    in
    {
      inherit fileAttrsMerged;
      nixosConfigurations = builtins.mapAttrs (
        name: data:
        withSystem data.labels.arch (
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
                ps.labels = data.labels;
                lib.hetzAttrs = {
                  id = data.id;
                  v4 = data.ipv4_address;
                  v6 = data.ipv6_address;
                };
              }
              ./default.nix
            ];
            inherit specialArgs;
          }
        )
      ) fileAttrsMerged;

      deploy.nodes = builtins.mapAttrs (name: data: {
        hostname = data.ipv4_address;
        profiles.system = {
          user = "root";
          sshUser = "root";
          path = inputs.deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.${name};
        };
      }) fileAttrs;

      # This is highly advised, and will prevent many possible mistakes
      checks = builtins.mapAttrs (
        system: deployLib: deployLib.deployChecks self.deploy
      ) inputs.deploy-rs.lib;
    };
}
