{ self, lib, config, pkgs, ... }:
{
  boot.tmp = {
    useTmpfs = true;
    tmpfsSize = "20G";
  };
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
}
