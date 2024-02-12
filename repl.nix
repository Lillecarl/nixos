let
  flake = builtins.getFlake (toString ./.);
  pkgs = import <nixpkgs> { };
  inherit (pkgs) lib;
  inherit (flake) nixosConfigurations;
in
{
  inherit flake pkgs lib nixosConfigurations;
  inherit (flake.nixosConfigurations) nub;
  shitbox = flake.nixosConfigurations.nub;
  nub_home = flake.homeConfigurations."lillecarl@nub";
  shitbox_home = flake.homeConfigurations."lillecarl@shitbox";
}
#// flake
#// builtins
#// nixpkgs
#// nixpkgs.lib
#// flake.nixosConfigurations
