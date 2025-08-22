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
          services.kubeadm = {
            advertiseAddress = "192.168.88.4";
            masterAddress = "192.168.88.4";
            roles = [
              "init"
              "worker"
            ];
          };
        };
        micro2 = {
          lib.micro.mac = "02:47:8B:D3:F1:02";
          lib.micro.ip4 = "192.168.88.5";
          services.kubeadm = {
            advertiseAddress = "192.168.88.5";
            masterAddress = "192.168.88.4";
            roles = [
              "controlPlane"
              "worker"
            ];
          };
        };
        micro3 = {
          lib.micro.mac = "02:47:8B:D3:F1:03";
          lib.micro.ip4 = "192.168.88.6";
          services.kubeadm = {
            advertiseAddress = "192.168.88.6";
            masterAddress = "192.168.88.4";
            cri = "cri-o";
            roles = [
              "worker"
            ];
          };
        };
      };
    in
    {
      nixosConfigurations = builtins.mapAttrs (
        name: module:
        withSystem system (
          {
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
