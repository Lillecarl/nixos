{ inputs, lib, ... }:
{
  flake = {
    colmena = {
      meta = {
        nixpkgs = import inputs.nixpkgs {
          system = "x86_64-linux";
          overlays = [
            #../pkgs
          ];
        };
        specialArgs = {
          inherit inputs;
          programs-sqlite-db = inputs.flake-programs-sqlite.packages."x86_64-linux".programs-sqlite;
        };
      };
      nub = {
        deployment = {
          allowLocalDeployment = true;
          targetHost = null;

          #targetHost = "somehost.tld";
          #targetPort = 1234;
          #targetUser = "luser";
        };
        imports = [
          ../nub/default.nix
          ../common
          ../common/flatpak.nix
          ../common/verycommon.nix
          ../common/keybindings.nix
          ../common/killservice.nix
          ../common/xplatform.nix
          ../modules/nixos/ifupdown2
          inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t14s
          inputs.nixos-hardware.nixosModules.common-cpu-amd
          inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
          inputs.nixos-hardware.nixosModules.common-gpu-amd
          inputs.nixos-hardware.nixosModules.common-pc-laptop
          inputs.nixos-hardware.nixosModules.common-pc-laptop-acpi_call
          inputs.nixos-hardware.nixosModules.common-pc-ssd
          inputs.nixos-hardware.nixosModules.common-pc
          inputs.dwarffs.nixosModules.dwarffs
        ];
      };
    };
  };
}
