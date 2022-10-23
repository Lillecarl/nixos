{ pkgs, hmUsers, ... }:

{
  #home-manager.users = { inherit (hmUsers) lillecarl; };

  users.users.lillecarl = {
    initialHashedPassword = "$6$ONUDqt1exFxDBPp.$mmPLQrgtFNJ543sZst.DoEAgVAyi5U8i2AWAXhDpoUGz0KDU.6QbXybsMtyPsMu5Q9nq2YKhfm5ca.oRHTVrm.";
    uid = 1000;
    shell = pkgs.zsh;
    isNormalUser = true;
    extraGroups = [
      "wheel" # enables sudo
      "libvirtd" # allow use of libvirt without sudo
      "networkmanager" # allow editing network connections without sudo
      "lxd" # allow userspace container management without sudo
      "flatpak" # allow managing flatpak
      "adbusers" # allow usage of adb
      "podman" # allow usage of adb
      "wireshark" # allow wireshark dumpcap
    ];
  };
}
