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
  nodes = {
    gw1 = {
      inherit system;
      extraModule = _: {
        ps.k3s.enable = false;
      };
    };
    k3s1 = { inherit system; };
  };
in
{
  flake = {
    nixosConfigurations = builtins.mapAttrs (
      name: value:
      withSystem (value.system or system) (
        {
          config,
          pkgs,
          repositoryLocation,
          ...
        }:
        let
          lib = pkgs.lib;
          specialArgs = {
            inherit
              inputs
              repositoryLocation
              self
              ;
          };
        in
        inputs.nixpkgs.lib.nixosSystem {
          inherit pkgs;
          modules = [
            ./default.nix
            {
              networking.hostName = name;
              ps.nodes.nodes = {
                k3s1 = {
                  ipv4Addr = "46.62.143.208";
                  ipv6Addr = "2a01:4f9:c012:6632::1";
                  diskPath = "/dev/disk/by-path/pci-0000:06:00.0-scsi-0:0:0:1";
                  ifName = "enp1s0";
                  ASN = 65012;
                };
              };
              ps.k3s = {
                package = pkgs.k3s_1_33;
                clusterCidr = "10.32.0.0/16";
                serviceCidr = "10.33.0.0/16";
                clusterDomain = "k8s.lillecarl.com";
              };
            }
          ] ++ lib.optional (value.extraModule or null != null) value.extraModule;
          inherit specialArgs;
        }
      )
    ) nodes;

    deploy.nodes = builtins.mapAttrs (
      name: value:
      withSystem system (
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
          hostname = self.nixosConfigurations.${name}.config.ps.nodes.node.ipv4Addr;
          profiles.system = {
            user = "root";
            sshUser = "root";
            path = deployPkgs.deploy-rs.lib.activate.nixos self.nixosConfigurations.${name};
          };
        }
      )
    ) nodes;
  };
}
