{ inputs
, self
, flakeloc
, bp
, ...
}:
let
  system = "aarch64-linux";
  images.pi = (self.nixosConfigurations.pi.extendModules {
    modules = [
      "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
      {
        disabledModules = [ "profiles/base.nix" ];
      }
    ];
  }).config.system.build.sdImage;

  nixosConfigurations.pi = inputs.nixpkgs.lib.nixosSystem {
    inherit system;
    modules = [
      "${inputs.nixpkgs}/nixos/modules/profiles/minimal.nix"
      inputs.disko.nixosModules.disko
      inputs.flake-programs-sqlite.nixosModules.programs-sqlite
      inputs.nixos-hardware.nixosModules.raspberry-pi-4
      inputs.stylix.nixosModules.stylix
      ./default.nix
      ./base.nix
      "${self}/common/fish.nix"
      "${self}/common/users.nix"
      "${self}/common/verycommon.nix"
      "${self}/common/stylix.nix"
      "${self}/common/nix.nix"
    ];
    specialArgs = {
      inherit inputs flakeloc bp self;
    };
  };
in
{
  flake = {
    images.pi = images.pi;

    #packages.x86_64-linux.pi-image = images.pi;
    #packages.aarch64-linux.pi-image = images.pi;

    nixosConfigurations.pi = nixosConfigurations.pi;
  };
}
