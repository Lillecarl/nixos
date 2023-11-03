{ lib, pkgs, config, modulesPath, ... }:

with lib;
let
  nixos-wsl = import ./nixos-wsl;
in
{
  imports = [
    "${modulesPath}/profiles/minimal.nix"
  ];

  services.tailscale.enable = true;

  networking = {
    hostName = "wsl"; # System hostname
  };
  wsl = {
    enable = true;
    automountPath = "/mnt";
    defaultUser = "lillecarl";
    startMenuLaunchers = true;

    # Enable native Docker support
    # docker-native.enable = true;

    # Enable integration with Docker Desktop (needs to be installed)
    # docker-desktop.enable = true;

  };

  system.stateVersion = "22.05";
}
