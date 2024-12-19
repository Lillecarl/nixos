{
  self,
  lib,
  config,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    inputs.disko.nixosModules.disko
    ../_shared
    ./configuration.nix
    ./disko.nix
    ./hardware-configuration.nix
    ./k3s.nix
    ./labels.nix
  ];

  config = {
    ps.polkit.enable = false;
    ps.verycommon.enable = false;
    
    networking.firewall.enable = false;
    services.openssh.enable = true;
    programs.git.enable = true;
    zramSwap = {
      enable = true;
      writebackDevice = config.disko.devices.disk.local.content.partitions.zramWriteback.device;
    };
    # Disable nix-serve that's normally enabled by the Nix module
    services.nix-serve.enable = lib.mkForce false;
    environment.systemPackages = [
      pkgs.gitui
    ];
    # Install LetsEncrypt staging as trusted root. This is "insecure" since LE
    # doesn't treat the staging keys with the same care as primary root keys.
    # However they still implement the same vertification solutions and such so
    # as long as I'm not targeted this is OK for a development machine using the
    # staging keys
    security.pki.certificateFiles = [
      "${self}/resources/letsencrypt-stg-root-x1.pem"
    ];
    security.polkit.enable = true;
    nix.package = lib.mkForce pkgs.lix;
    programs.ssh.extraConfig = ''
      Host eu.nixbuild.net
        PubkeyAcceptedKeyTypes ssh-ed25519
        ServerAliveInterval 60
        IPQoS throughput
        IdentityFile /home/lillecarl/.ssh/id_ed25519
    '';

    programs.ssh.knownHosts = {
      nixbuild = {
        hostNames = [ "eu.nixbuild.net" ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPIQCZc54poJ8vqawd8TraNryQeJnvH1eLpIDgbiqymM";
      };
    };
  };
}
