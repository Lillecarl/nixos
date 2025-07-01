{
  lib,
  config,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    inputs.disko.nixosModules.disko
    ./users.nix
    ./configuration.nix
    ./disko.nix
    ./hardware-configuration.nix
    ./k3s.nix
    ./networking.nix
  ];

  config = {
    programs.git.enable = true;

    # Don't wait for online anything
    systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;
    # Disable nix-serve that's normally enabled by the Nix module
    services.nix-serve.enable = lib.mkForce false;
    services.openssh = {
      enable = true;
    };
    environment.enableAllTerminfo = true;
    environment.systemPackages = [
      pkgs.gitui
    ];
    # Install LetsEncrypt staging as trusted root. This is "insecure" since LE
    # doesn't treat the staging keys with the same care as primary root keys.
    # However they still implement the same vertification solutions and such so
    # as long as I'm not targeted this is OK for a development machine using the
    # staging keys
    security.pki.certificateFiles = [
      ./letsencrypt-stg-root-x1.pem
      ./letsencrypt-stg-root-x2-signed-by-x1.pem
    ];
    security.polkit.enable = true;
    nix.package = lib.mkForce pkgs.lix;
  };
}
