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

      # VM bridge
      auto br13
      iface br13 inet static
          address 10.13.37.1
          netmask 255.255.255.0
          bridge-ports none
          bridge-stp off
          bridge-fd 0
          bridge-maxwait 0
          post-up iptables -t nat -A POSTROUTING -s 10.13.37.1/24 -j MASQUERADE
          pre-down iptables -t nat -D POSTROUTING -s 10.13.37.1/24 -j MASQUERADE
    '';
  };
}
