{ config
, lib
, ...
}:
{
  # Disable systemd-networkd-wait-online, we just want a bridge to add VM's to.
  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;

  networking = {
    nftables = {
      enable = true;

      tables.carl = {
        family = "inet";
        content = builtins.readFile ./carl.nft;
      };
    };
    firewall = {
      enable = true;
    };
  };

  systemd.network = {
    enable = true;

    netdevs = {
      # Dummy interface to add to bridge(s) that we always want up.
      dummy0 = {
        netdevConfig = {
          Kind = "dummy";
          Name = "dummy0";
        };
      };

      br13 = {
        netdevConfig = {
          Kind = "bridge";
          Name = "br13";
        };
      };
    };
    networks = {
      # Dummy interface to add to bridge(s) that we always want up.
      dummy0 = {
        matchConfig.Name = config.systemd.network.netdevs.dummy0.netdevConfig.Name;
        # Bridge(s) to add this interface to.
        bridge = [
          config.systemd.network.netdevs.br13.netdevConfig.Name
        ];
      };

      br13 = {
        matchConfig.Name = config.systemd.network.netdevs.br13.netdevConfig.Name;
        name = "br13";
        address = [ "10.13.37.1/24" ];
      };
    };
  };
}
