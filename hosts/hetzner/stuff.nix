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
}
