{ config
, pkgs
, lib
, inputs
, system
, ...
}:
{
  environment.systemPackages = [
    inputs.disko.packages.${pkgs.system}.default
  ];

  system.stateVersion = "23.05";
}
