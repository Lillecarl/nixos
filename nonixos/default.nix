{ config
, pkgs
, lib
, ... }:

{
  nixpkgs.overlays = [
    (import ./overlay.nix)
  ];
  boot.kernel.enable = false;
  services.dbus.enable = lib.mkForce false;
  systemd.package = pkgs.systemd.override {
  };
  systemd.oomd.enable = false;
  systemd.coredump.enable = false;
  systemd.services.systemd-importd.enable = false;
  systemd.services.systemd-modules-load.enable = true;
  systemd.services.container-.enable = false;
  environment.defaultPackages = lib.mkForce [];

  # Required to build nixos
  fileSystems = { "/" = { device = "/dev/null"; }; };
  boot.loader.grub.device = "nodev";

  system.stateVersion = "22.11"; # Did you read the comment?

}
