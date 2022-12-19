{
  description = "Viaplay central nix flake repository";

  inputs = {
    # Specify the source of Home Manager and nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/release-22.11";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      homeConfigurations.root = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [ ./root.nix ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
      };
      packages.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux;
      defaultPackage.x86_64-linux = import ./profile.nix { inherit pkgs; };
    };
}

