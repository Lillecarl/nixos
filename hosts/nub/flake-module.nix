{ self
, inputs
, withSystem
, __curPos ? __curPos
, ...
}@top:
let
  system = "x86_64-linux";
in
{
  flake = {
    nixosConfigurations.nub =
      withSystem system ({ config, pkgs, flakeloc, flakepath, ... }@ctx:
        let
          specialArgs = {
            inherit inputs flakeloc flakepath self;
          };
        in
        inputs.nixpkgs.lib.nixosSystem {
          inherit pkgs;
          modules = [
            (self + "/stylix.nix")
            inputs.agenix.nixosModules.default
            inputs.disko.nixosModules.disko
            inputs.lanzaboote.nixosModules.lanzaboote
            inputs.niri.nixosModules.niri
            inputs.nixos-hardware.nixosModules.common-pc-laptop-acpi_call
            inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen3
            inputs.stylix.nixosModules.stylix
            inputs.catppuccin-nix.nixosModules.catppuccin
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = specialArgs;
              home-manager.users.root = { nixosConfig, ... }:
                {
                  imports = pkgs.lib.rimport {
                    path = [ ../../users/_shared ../../users/root ];
                    regdel = ".*_shared/gui/.*";
                  };
                  home.stateVersion = nixosConfig.system.stateVersion;
                };
            }
            (_: { catppuccin.enable = true; })
          ]
          ++ pkgs.lib.rimport {
            path = [ ./. ../_shared ];
            regdel = __curPos.file;
          };
          inherit specialArgs;
        });
  };
}
