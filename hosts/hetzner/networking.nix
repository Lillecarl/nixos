{ ... }:
{
  networking.useDHCP = false;
  networking.interfaces.enp1s0.useDHCP = false;
  systemd.network.enable = true;
  systemd.network.networks."30-wan" = {
    matchConfig.Name = "enp1s0"; # either ens3 (amd64) or enp1s0 (arm64)
    networkConfig.DHCP = "no";
    address = [
      "65.21.63.133/32"
      "fe80::9400:3ff:feec:ce8f/64"
    ];
    routes = [
      {
        Gateway = "172.31.1.1";
        GatewayOnLink = true;
      }
      {
        Gateway = "172.31.1.1";
        GatewayOnLink = true;
        Destination = "169.254.169.254/32";
      }
      {
        Gateway = "fe80::1";
      }
    ];
  };
}
