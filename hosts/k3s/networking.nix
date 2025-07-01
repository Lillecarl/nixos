{ config, ... }:
{
  networking.useDHCP = false;
  networking.interfaces.enp1s0.useDHCP = true;
  networking.nameservers = [
    "2620:fe::fe"
    "9.9.9.9"
  ];
  systemd.network.enable = true;
  # systemd.network.networks."30-wan" = {
  #   matchConfig.Name = "enp1s0"; # either ens3 (amd64) or enp1s0 (arm64)
  #   networkConfig.DHCP = "no";
  #   address = [
  #     "${config.lib.hetzAttrs.v4}/32"
  #     "${config.lib.hetzAttrs.v6}/64"
  #   ];
  #   routes = [
  #     {
  #       Gateway = "172.31.1.1";
  #       GatewayOnLink = true;
  #     }
  #     {
  #       Gateway = "172.31.1.1";
  #       GatewayOnLink = true;
  #       Destination = "169.254.169.254/32";
  #     }
  #     {
  #       Gateway = "fe80::1";
  #       GatewayOnLink = true;
  #     }
  #   ];
  # };
}
