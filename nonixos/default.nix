{ config
, pkgs
, lib
, ...
}:

{
  nixpkgs.overlays = [
    (import ./overlay.nix)
  ];

  boot.enableContainers = false;
  boot.kernel.enable = false;
  boot.loader.grub.device = "nodev";
  systemd.package = pkgs.systemd.override { };
  systemd.oomd.enable = false;
  systemd.coredump.enable = false;
  environment.systemPackages = lib.mkForce [ ];
  environment.defaultPackages = lib.mkForce [ ];
  services.dbus.enable = lib.mkForce false;
  # Required to build nixos
  fileSystems = { "/" = { device = "/dev/null"; }; };

  system.stateVersion = "22.11";
}
