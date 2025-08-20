{
  self,
  inputs,
  withSystem,
  __curPos ? __curPos,
  ...
}:
let
  system = "x86_64-linux";
in
{
  flake =
    let
      hosts = {
        micro1 = {
          lib.micro.mac = "02:47:8B:D3:F1:01";
          lib.micro.ip4 = "192.168.88.4";
        };
        micro2 = {
          lib.micro.mac = "02:47:8B:D3:F1:02";
          lib.micro.ip4 = "192.168.88.5";
        };
        micro3 = {
          lib.micro.mac = "02:47:8B:D3:F1:03";
          lib.micro.ip4 = "192.168.88.6";
        };
      };
    in
    {
      nixosConfigurations = builtins.mapAttrs (
        name: module:
        withSystem system (
          {
            config,
            pkgs,
            repositoryLocation,
            ...
          }:
          let
            specialArgs = {
              inherit inputs repositoryLocation self;
            };
          in
          inputs.nixpkgs.lib.nixosSystem {
            inherit pkgs;
            modules = [
              {
                networking.hostName = name;
              }
              module
              ./default.nix
            ];
            inherit specialArgs;
          }
        )
      ) hosts;
    };
}
