{
  lib,
  pkgs,
  config,
  modulesPath,
  ...
}:
{
  imports = [
    ../_shared/users.nix
    ../_shared/nix.nix
    ../_shared/fish.nix
  ];
  boot.loader = {
    systemd-boot = {
      enable = true;
    };
  };

  time.timeZone = "Europe/Stockholm";
  services.openssh.enable = true;
  system.stateVersion = "23.11";
}
