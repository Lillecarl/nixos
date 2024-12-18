{ inputs, ... }:
{
  imports = [
    inputs.disko.nixosModules.disko
    ../_shared/nix.nix
    ../_shared/noshell.nix
    ../_shared/users.nix
    ./configuration.nix
    ./disko.nix
    ./hardware-configuration.nix
    ./k3s.nix
    ./labels.nix
    ./stuff.nix
  ];
}
