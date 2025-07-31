{
  pkgs ? import <nixpkgs> { },
}:
pkgs.fetchFromGitHub {
  owner = "lillecarl";
  repo = "nixos";
  rev = "master";
}
