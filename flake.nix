{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
    nixos-hardware.url = github:NixOS/nixos-hardware/master;
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs-channel.url = "https://nixos.org/channels/nixos-unstable/nixexprs.tar.xz";
    dwarffs = {
      url = "github:edolstra/dwarffs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = github:nix-community/home-manager;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = github:pjones/plasma-manager;
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = { self, nixpkgs, nixos-hardware, home-manager, dwarffs, ... } @inputs:
    let
      system = "x86_64-linux";
      #pkgs = import nixpkgs { system = "x86_64-linux"; config = { allowUnfree = true; }; };
      pkgs = import nixpkgs { system = system; config = { allowUnfree = true; }; };
    in
    {
      nixosConfigurations = rec {
        shitbox = nixpkgs.lib.nixosSystem {
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
          specialArgs = { inherit inputs; };
        };
        nub = nixpkgs.lib.nixosSystem
          {
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
              nixos-hardware.nixosModules.common-cpu-amd-pstate
              nixos-hardware.nixosModules.common-gpu-amd
              nixos-hardware.nixosModules.common-pc-laptop
              nixos-hardware.nixosModules.common-pc-laptop-acpi_call
              nixos-hardware.nixosModules.common-pc-ssd
              nixos-hardware.nixosModules.common-pc
              dwarffs.nixosModules.dwarffs

              home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.backupFileExtension = "old"; # Move non-hm files if they're in the way
                home-manager.users.lillecarl = import ./lillecarl;

                home-manager.sharedModules = [ inputs.plasma-manager.homeManagerModules.plasma-manager ];

                # Optionally, use home-manager.extraSpecialArgs to pass
                # arguments to home.nix
              }
            ];
            specialArgs = { inherit inputs; };
          };
      };
      homeConfigurations = {
        lillecarl = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./lillecarl
            inputs.plasma-manager.homeManagerModules.plasma-manager
          ];
        };
      };
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
      packages.x86_64-linux = {
        acme-dns = pkgs.callPackage ./pkgs/acme-dns { };
      };
    };
}
