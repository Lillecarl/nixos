{
  inputs = {
    unstable.url = github:NixOS/nixpkgs/nixos-unstable;
    nixos-hardware.url = github:NixOS/nixos-hardware/master;
  };

  outputs = { self, unstable, nixos-hardware, ... } @inputs:
    let
      nixpkgsConfig = {
        config = { allowUnfree = true; };
      };
    in
    {
      nixosConfigurations = rec {
        shitbox = unstable.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./shitbox
            nixos-hardware.nixosModules.common-cpu-intel
            nixos-hardware.nixosModules.common-pc-ssd
            nixos-hardware.nixosModules.common-pc
          ];
        };
        lemur = unstable.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./lemur
            nixos-hardware.nixosModules.common-cpu-intel
            nixos-hardware.nixosModules.common-pc-laptop
            nixos-hardware.nixosModules.common-pc-ssd
            nixos-hardware.nixosModules.common-pc
            nixos-hardware.nixosModules.system76
          ];
        };
      };
    };
}
