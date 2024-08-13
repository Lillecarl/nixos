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

      # reserved tables: filter, nixos-fw, nat (maybe more?)

      tables.masq = {
        family = "inet";
        content = ''
          chain nat {
            type nat hook postrouting priority mangle;
            ip saddr == 10.13.37.0/24 ip daddr != 10.13.37.0/24 masquerade comment "Masquerade VM traffic"
            iifname == br13 oifname != br13 masquerade comment "Masquerade VM traffic"
          }
        '';
      };
    };
    firewall = {
      enable = true;
      allowPing = true;

      extraInputRules = ''
        ip6 nexthdr icmpv6 icmpv6 type { destination-unreachable, packet-too-big, time-exceeded, parameter-problem, nd-router-advert, nd-neighbor-solicit, nd-neighbor-advert, mld-listener-query, nd-router-solicit } accept comment "Allow icmpv6 identification"
        ip protocol icmp icmp type { destination-unreachable, router-advertisement, time-exceeded, parameter-problem } accept comment "Allow icmpv4 identification"
      '';
    };
    networkmanager.unmanaged = lib.attrNames config.systemd.network.netdevs;
  };

  systemd.network = {
    enable = true;

    netdevs = {
      # Dummy interface to add to bridge(s) that we always want up.
      dummy0 = {
        netdevConfig = {
          Name = "dummy0";
          Kind = "dummy";
        };
      };

      br13 = {
        netdevConfig = {
          Name = "br13";
          Kind = "bridge";
        };
      };
    };

    networks = {
      # Dummy interface to add to bridge(s) that we always want up.
      dummy0 = {
        # Match with dummy netdev by name
        matchConfig.Name = config.systemd.network.netdevs.dummy0.netdevConfig.Name;
        # Bridge(s) to add this interface to.
        # br13 is our bridge for VM's
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
