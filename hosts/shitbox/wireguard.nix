{ config, ... }:
{
  options = { };
  config = {
    networking.wireguard.interfaces.hetzner1 = {
      mtu = 1280;
      allowedIPsAsRoutes = false;
      privateKeyFile = "/etc/wireguard/private.key";
      ips = [ "10.44.33.2/24" ];

      peers = [
        {
          name = "hetzner1";
          publicKey = "T0x47QL79R7pwBAOoR1WqiwjKixvH/QcCyWKHaH5Bwc=";
          endpoint = "65.21.63.133:51820";
          allowedIPs = [ "0.0.0.0/0" ];
          persistentKeepalive = 25;
        }
      ];
    };
  };
}
