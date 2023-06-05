{ config
, pkgs
, lib
, ...
}:
let
  etcOut = path: config.environment.etc.${path}.source.outPath;
in
{
  nixpkgs.overlays = [
    (import ./overlay.nix)
  ];

  imports = [
    ./module.nix
  ];

  nonixos.files = {
    "/etc/whatever" = { source = config.environment.etc."nix/nix.conf".source.outPath; };
    "/etc/whatever2" = { source = etcOut "nix/nix.conf"; };
  };

  environment.etc = {
    "/etc/whatever" = { text = "whatever"; };
  };

  boot.enableContainers = false;
  #boot.kernel.enable = false;
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
