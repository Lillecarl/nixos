{
  inputs = {
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    stable.url = "github:NixOS/nixpkgs/nixos-21.11";
    nixos-hardware.url = github:NixOS/nixos-hardware/master;
  };

  outputs = { self, stable, unstable, nixos-hardware, ... } @ args: {
    nixosConfigurations.shitbox = (let nixpkgs = unstable; in nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./shitbox
        nixos-hardware.nixosModules.common-cpu-intel
        nixos-hardware.nixosModules.common-pc-ssd
        nixos-hardware.nixosModules.common-pc
      ];
    });
    nixosConfigurations.lemur = (let nixpkgs = stable; in nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./lemur.nix
        nixos-hardware.nixosModules.common-cpu-intel
        nixos-hardware.nixosModules.common-pc-laptop
        nixos-hardware.nixosModules.common-pc-ssd
        nixos-hardware.nixosModules.common-pc
        nixos-hardware.nixosModules.system76
      ];
    });
  };
}
