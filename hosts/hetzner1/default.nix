{ inputs, ... }:
{
  imports = [
    inputs.disko.nixosModules.disko
    ./users.nix
    ./configuration.nix
    ./disko.nix
    ./hardware-configuration.nix
  ];
}
