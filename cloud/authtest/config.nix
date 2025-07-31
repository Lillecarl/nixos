{ config, lib, pkgs, ... }:
{
  imports = [
    ../nix
  ];

  config = {
    state = "authtest";
    remoteStates = [ ];
  };
}
