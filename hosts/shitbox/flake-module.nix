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
    nixosConfigurations.shitbox =
      withSystem system ({ pkgs, flakeloc, flakepath, ... }@ctx:
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
            inputs.niri.nixosModules.niri
            inputs.nixos-hardware.nixosModules.common-cpu-amd
            inputs.nixos-hardware.nixosModules.common-gpu-intel
            inputs.nixos-hardware.nixosModules.common-pc
            inputs.nixos-hardware.nixosModules.common-pc-ssd
            inputs.stylix.nixosModules.stylix
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
          ]
          ++ pkgs.lib.rimport { path = [ ./. ../_shared ]; regdel = [ __curPos.file ".*disko\.nix" ]; };
          inherit specialArgs;
        });
  };
}
