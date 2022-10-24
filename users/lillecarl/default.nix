{ pkgs, hmUsers, ... }:

{
  #home-manager.users = { inherit (hmUsers) lillecarl; };

  users.users.lillecarl = {
    initialHashedPassword = "$6$cQj59HFxckoo6edO$K52bjvtmBAFVlUVdCoLCURYbXYW.SM461pR4sq9jK7c/v1qy8caVOCthu4jfHTdhFwXLVKwe6WjV2grmH1l0b/";
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
