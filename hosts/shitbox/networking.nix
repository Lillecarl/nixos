{ lib, config, ... }:
let
  modName = "networking";
  cfg = config.ps.${modName};
in
{
  options.ps = {
    ${modName} = {
      enable = lib.mkOption {
        default = false;
        description = "Whether to enable ${modName}.";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    lib = {
      lobr = rec {
        first24 = "10.13.37";
        ip = "${first24}.1";
        network = "${first24}.0";
        mask = "24";
        name = "lobr";
      };
    };

    networking = {
      dhcpcd.enable = false; # systemd-networkd does this for us

      nftables = {
        enable = true;

        # reserved tables: filter, nixos-fw, nat (maybe more?)

        tables.masq = {
          family = "inet";
          content = ''
            chain nat {
              type nat hook postrouting priority mangle;
              ip saddr == ${config.lib.lobr.network}/${config.lib.lobr.mask} ip daddr != ${config.lib.lobr.network}/${config.lib.lobr.mask} masquerade comment "Masquerade VM traffic"
              iifname == ${config.lib.lobr.name} oifname != ${config.lib.lobr.name} masquerade comment "Masquerade VM traffic"
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

      wireless = {
        iwd = {
          # enable = true;
        };
      };
    };

    systemd.network = {
      enable = true;
      wait-online.enable = false;

      netdevs = {
        # Dummy interface to add to bridge(s) that we always want up.
        dummy0 = {
          netdevConfig = {
            Name = "dummy0";
            Kind = "dummy";
          };
        };
        br0 = {
          netdevConfig = {
            Name = "br0";
            Kind = "bridge";
            MACAddress = "02:00:00:12:34:56";
          };
        };
        br1 = {
          netdevConfig = {
            Name = "br1";
            Kind = "bridge";
            MACAddress = "02:00:00:12:34:58";
          };
        };
        vxlan1 = {
          netdevConfig = {
            Kind = "vxlan";
            Name = "vxlan1";
          };
          vxlanConfig = {
            VNI = 1;
            Local = "192.168.88.2";
            Remote = "192.168.88.1";
            DestinationPort = 4789;
            Independent = true;
          };
        };
        ${config.lib.lobr.name} = {
          netdevConfig = {
            Name = config.lib.lobr.name;
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
            config.systemd.network.netdevs.${config.lib.lobr.name}.netdevConfig.Name
            "br0"
          ];
          networkConfig = {
            IPv4Forwarding = false;
            IPv6Forwarding = false;
          };
        };

        br0 = {
          matchConfig.Name = "br0";
          address = [
            "192.168.88.2/24"
          ];
          networkConfig = {
            DHCP = "ipv4";
          };
        };
        br1 = {
          matchConfig.Name = "br1";
          address = [
            "192.168.89.2/24"
          ];
          networkConfig = {
            DHCP = "ipv4";
          };
        };
        vxlan1 = {
          matchConfig.Name = "vxlan1";
          address = [
            "2001:470:28:f5::2/64"
          ];
          networkConfig = {
            IPv6AcceptRA = false;
            # VXLAN = "vxlan1";
          };
          routes = [
            {
              # Destination = "::0";
              Gateway = "2001:470:28:f5::1";
            }
          ];
          linkConfig = {
            MTUBytes = 1400;
          };
        };

        enp8s0 = {
          matchConfig.Name = "enp8s0";
          bridge = [ "br0" ];
          DHCP = "no";
        };

        br13 = {
          matchConfig.Name = config.systemd.network.netdevs.${config.lib.lobr.name}.netdevConfig.Name;
          inherit (config.lib.lobr) name;
          address = [ "${config.lib.lobr.ip}/${config.lib.lobr.mask}" ];
        };
        loopback = {
          matchConfig.Name = "lo";
          addresses = [
            {
              Address = "127.0.0.1/8";
            }
            {
              Address = "::1/128";
            }
            {
              Address = "10.13.39.1/32";
            }
          ];
          linkConfig.RequiredForOnline = false;
        };
      };
    };
  };
}
