{
  inputs = {
    nixos-unstable.url = github:NixOS/nixpkgs/nixos-unstable;
    nixos-hardware.url = github:NixOS/nixos-hardware/master;
    flake-utils.url = "github:numtide/flake-utils";
    nixos-unstable-channel.url = "https://nixos.org/channels/nixos-unstable/nixexprs.tar.xz";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixos-unstable";
    };
  };

  outputs = { self, nixos-unstable, nixos-hardware, home-manager, ... } @inputs:
  let
    system = "x86_64-linux";
    pkgs = import nixos-unstable { system = "x86_64-linux"; config = { allowUnfree = true; }; };
  in
  {

    nixosConfigurations = rec {
      shitbox = nixos-unstable.lib.nixosSystem {
        inherit system;
        modules = [
          ./shitbox
          ./common
          ./common/flatpak.nix
          ./common/keybindings.nix
          ./common/killservice.nix
          nixos-hardware.nixosModules.common-cpu-amd
          nixos-hardware.nixosModules.common-pc-ssd
          nixos-hardware.nixosModules.common-pc
        ];
        specialArgs = inputs;
      };
      nub = nixos-unstable.lib.nixosSystem {
        inherit system;
        modules = [
          ./nub
          ./common
          ./common/flatpak.nix
          ./common/keybindings.nix
          ./common/killservice.nix
          ./common/xplatform.nix
          nixos-hardware.nixosModules.lenovo-thinkpad-t14s
          nixos-hardware.nixosModules.common-cpu-amd
          nixos-hardware.nixosModules.common-gpu-amd
          nixos-hardware.nixosModules.common-pc-laptop
          nixos-hardware.nixosModules.common-pc-laptop-acpi_call
          nixos-hardware.nixosModules.common-pc-ssd
          nixos-hardware.nixosModules.common-pc

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "old"; # Move non-hm files if they're in the way
            home-manager.users.lillecarl = import ./lillecarl;

            # Optionally, use home-manager.extraSpecialArgs to pass
            # arguments to home.nix
          }
        ];
        specialArgs = inputs;
      };
    };
    homeConfigurations = {
      lillecarl = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./lillecarl
        ];
      };
    };
  };
}
