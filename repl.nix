let
  host = builtins.getEnv "HOST";
  _flakePath = /home/lillecarl/Code/nixos;
  flake = builtins.getFlake (toString _flakePath);
  inherit (flake.nixosConfigurations) nub;
  inherit (flake.nixosConfigurations) shitbox;
  bs = builtins;
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
rec {
  inherit
    flake
    pkgs
    lib
    nixosConfigurations
    nub
    shitbox
    host;

  self = flake;

  slib = import ./lib { outPath = self.outPath; inherit lib; };
  nub_home = flake.homeConfigurations."lillecarl@nub";
  shitbox_home = flake.homeConfigurations."lillecarl@shitbox";
}
