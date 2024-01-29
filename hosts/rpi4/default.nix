{ config
, pkgs
, ...
}:
{
  programs.command-not-found.enable = true;

  environment.systemPackages = with pkgs; [ vim git ];
  services.openssh.enable = true;
  networking.hostName = "pi";
  users = {
    users.lillecarl = {
      password = "password123";
      isNormalUser = true;
      extraGroups = [ "wheel" ];
    };
  };
  networking = {
    interfaces."wlan0".useDHCP = true;
    wireless = {
      interfaces = [ "wlan0" ];
      enable = true;
      networks = {
        "434".psk = "penthouse";
      };
    };
  };

  system.stateVersion = "24.05";
}
