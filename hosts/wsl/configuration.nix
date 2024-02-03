{ modulesPath, ... }:
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
  };

  system.stateVersion = "22.05";
}
