{ config, lib, pkgs, ... }:
{
  imports = [
    ../nix
  ];

  config = {
    state = "hostfirewall";
    remoteStates = [ ];
  };
}
