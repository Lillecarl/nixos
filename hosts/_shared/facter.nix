{ inputs, ... }:
{
  imports = [
    inputs.nixos-facter-modules.nixosModules.facter
  ];
}
