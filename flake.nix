{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
  };

  outputs = { self, nixpkgs }: {
    packages.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux;
  };
}
