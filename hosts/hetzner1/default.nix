{ inputs, ... }:
{
  imports = [
    inputs.disko.nixosModules.disko
    ../_shared/noshell.nix
    ../_shared/users.nix
    ../_shared/nix.nix
    ./configuration.nix
    ./disko.nix
    ./hardware-configuration.nix
    ./k3s.nix
  ];
}
