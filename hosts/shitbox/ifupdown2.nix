{ pkgs, self, ... }:
{
  imports = [
    "${self}/modules/nixos/ifupdown2"
  ];
  networking.ifupdown2 = {
    enable = true;

    extraPackages = [
      pkgs.bridge-utils
      pkgs.dpkg
      pkgs.ethtool
      pkgs.iproute2
      pkgs.kmod
      pkgs.mstpd
      pkgs.openvswitch
      pkgs.ppp
      pkgs.procps
      pkgs.pstree
      pkgs.service-wrapper
      pkgs.systemd
      pkgs.iptables
    ];

    extraConfig = ''
      auto lo
      iface lo inet loopback

      # Dummy to keep br13 up
      auto dummy0
      iface dummy0 inet manual
        pre-up ip link add dummy0 type dummy

      # VM bridge
      auto br13
      iface br13 inet static
          address 10.13.37.1
          netmask 255.255.255.0
          bridge-ports dummy0
          bridge-stp off
          bridge-fd 0
          bridge-maxwait 0
          post-up iptables -t nat -A POSTROUTING -o br13 -j MASQUERADE
          pre-down iptables -t nat -D POSTROUTING -o br13 -j MASQUERADE
    '';
  };
}
