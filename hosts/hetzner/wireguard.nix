{ config, ... }:
{
  options = { };
  config = {
    networking.wireguard.interfaces.clients = {
      mtu = 1280;
      allowedIPsAsRoutes = false;
      privateKeyFile = "/etc/wireguard/private.key";
      ips = [ "10.44.33.1/24" ];
      listenPort = 51820;

      peers = [
        {
          name = "shitbox";
          publicKey = "nPky+d8cQ0dT5IfS3NPJX4v3Vmy/YegsLscY2vSWa3U=";
          allowedIPs = [
            "0.0.0.0/0"
            "::/0"
          ];
          persistentKeepalive = 25;
        }
      ];
    };
  };
}
