{ inputs
, flakeloc
, self
, ...
}:
{
  flake = {
    nixosConfigurations.shitbox = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ../../common
        ../../common/acme.nix
        ../../common/fish.nix
        ../../common/hyprland.nix
        ../../common/nix.nix
        ../../common/overlays.nix
        ../../common/stylix.nix
        ../../common/users.nix
        ../../common/verycommon.nix
        ../../common/xdg.nix
        ./default.nix
        inputs.agenix.nixosModules.default
        inputs.disko.nixosModules.disko
        inputs.flake-programs-sqlite.nixosModules.programs-sqlite
        inputs.niri.nixosModules.niri
        inputs.nixos-hardware.nixosModules.common-cpu-amd
        inputs.nixos-hardware.nixosModules.common-gpu-intel
        inputs.nixos-hardware.nixosModules.common-pc
        inputs.nixos-hardware.nixosModules.common-pc-ssd
        inputs.stylix.nixosModules.stylix
        ({ pkgs, ... }: {
          programs.niri = {
            enable = true;
            package = pkgs.niri-unstable;
          };
        })
      ];
      specialArgs = {
        inherit inputs self flakeloc;
      };
    };
  };
}
