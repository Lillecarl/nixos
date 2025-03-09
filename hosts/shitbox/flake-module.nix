{
  self,
  inputs,
  withSystem,
  __curPos ? __curPos,
  ...
}@top:
let
  system = "x86_64-linux";
in
{
  flake = {
    nixosConfigurations.shitbox = withSystem system (
      { pkgs, flakeloc, ... }@ctx:
      let
        specialArgs = {
          inherit inputs flakeloc self;
        };
      in
      inputs.nixpkgs.lib.nixosSystem {
        inherit pkgs;
        modules =
          [
            {
              ps.networking.enable = true;
              ps.workstation.enable = true;
              ps.libvirt.enable = true;
              ps.kea.enable = true;
              ps.btrfs.enable = true;
              ps.guix.enable = true;
              ps.kerneltune.enable = true;
              ps.acme.enable = true;
              ps.secrets.enable = true;
            }
            inputs.agenix.nixosModules.default
            inputs.disko.nixosModules.disko
            inputs.niri.nixosModules.niri
            inputs.nixos-hardware.nixosModules.common-cpu-amd
            inputs.nixos-hardware.nixosModules.common-gpu-intel
            inputs.nixos-hardware.nixosModules.common-pc
            inputs.nixos-hardware.nixosModules.common-pc-ssd
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = specialArgs;
            }
          ]
          ++ pkgs.lib.rimport {
            path = [
              ./.
              ../_shared
            ];
            regdel = [
              __curPos.file
              ".*disko\.nix"
            ];
          };
        inherit specialArgs;
      }
    );
  };
}
