let
  host = builtins.getEnv "HOST";
  flake = builtins.getFlake (toString ./.);
  inherit (flake.nixosConfigurations) nub;
  inherit (flake.nixosConfigurations) shitbox;
  pkgs =
    if
      host == "nub" then nub.pkgs
    else if
      host == "shitbox" then shitbox.pkgs
    else
      throw "Unknown host ${host}";
  inherit (pkgs) lib;
  inherit (flake) nixosConfigurations;
in
{
  inherit
    flake
    pkgs
    lib
    nixosConfigurations
    nub
    shitbox
    host;

  nub_home = flake.homeConfigurations."lillecarl@nub";
  shitbox_home = flake.homeConfigurations."lillecarl@shitbox";
}
#// flake
#// builtins
#// nixpkgs
#// nixpkgs.lib
#// flake.nixosConfigurations
