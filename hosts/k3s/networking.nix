{
  config,
  lib,
  pkgs,
  ...
}:
let
  modName = "networking";
  cfg = config.ps.${modName};
in
{
  options.ps = {
    ${modName} = {
      enable = lib.mkOption {
        default = true;
        description = "Whether to enable ${modName}.";
      };
      ifName = lib.mkOption {
        type = lib.types.str;
      };
      addresses = lib.mkOption {
        type = lib.types.listOf lib.types.str;
      };
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.services.systemd-networkd.environment = {
      Environment = "SYSTEMD_LOG_LEVEL=debug";
    };
    networking.useDHCP = false;
    networking.interfaces.${cfg.ifName}.useDHCP = lib.mkDefault true;
    networking.nameservers = lib.mkDefault [
      # quad9
      "2620:fe::fe"
      "9.9.9.9"
    ];
    systemd.network.enable = true;
    systemd.network.networks.${cfg.ifName} = {
      matchConfig.Name = cfg.ifName; # either ens3 (amd64) or enp1s0 (arm64)
      networkConfig.DHCP = true;
      dhcpV4Config.UseDNS = false;
      address = [
        (config.ps.nodes.node.ipv4Addr)
        (config.ps.nodes.node.ipv6Addr)
      ];
      routes = [
        {
          Gateway = "fe80::1";
          GatewayOnLink = true;
        }
      ];
    };
    systemd.network.netdevs.dummy0 = {
      netdevConfig = {
        Name = "dummy0";
        Kind = "dummy";
      };
    };

    systemd.network.networks.dummy0 = {
      matchConfig.Name = config.systemd.network.netdevs.dummy0.netdevConfig.Name;
      bridge = [
        "br1"
      ];
      networkConfig = {
        IPv4Forwarding = false;
        IPv6Forwarding = false;
      };
    };

    systemd.network.netdevs.br1 = {
      netdevConfig = {
        Name = "br1";
        Kind = "bridge";
      };
      bridgeConfig = {
        VLANFiltering = true;
        DefaultPVID = "none";
      };
      netdevConfig  = {
        MTUBytes = 1400;
      };
    };
    systemd.network.networks.br1 = {
      matchConfig.Name = "br1";
      networkConfig = {
        DHCP = "no";
        IPv4Forwarding = true;
        IPv6Forwarding = true;
      };
      bridgeVLANs = [
        { VLAN = 1; }
      ];
      vlan = [ "vlan1" ];
      vxlan = [ "vxlan1" ];
    };

    systemd.network.netdevs.vxlan1 = {
      netdevConfig = {
        Name = "vxlan1";
        Kind = "vxlan";
      };
      vxlanConfig = {
        VNI = 1;
        Local = config.ps.nodes.node.ipv4Addr;
        DestinationPort = 4789;
        # Independent = true;
        MacLearning = false;
      };
    };
    # systemd.network.networks.vxlan1 = {
    #   matchConfig.Name = "vxlan1";
    #   networkConfig.Bridge = "br1";
    #   bridgeConfig = {
    #     NeighborSuppression = true;
    #     Learning = false;
    #   };
    #   bridgeVLANs = [
    #     {
    #       VLAN = 1;
    #       PVID = 1;
    #       EgressUntagged = 1;
    #     }
    #   ];
    #   linkConfig = {
    #     MTUBytes = 1400;
    #   };
    # };

    systemd.network.netdevs.vlan1 = {
      netdevConfig = {
        Kind = "vlan";
        Name = "vlan1";
      };
      vlanConfig = {
        Id = 1;
      };
    };
    # systemd.network.networks.vlan1 = {
    #   matchConfig.Name = "vlan1";
    #   addresses =
    #     if config.networking.hostName == "gw01" then
    #       [ { Address = "10.0.0.1/30"; } ]
    #     else
    #       [ { Address = "10.0.0.2/30"; } ];
    #   networkConfig = {
    #     Bridge = "br1";
    #     VLAN = "vlan1";
    #   };
    #   bridgeVLANs = [
    #     {
    #       VLAN = 1;
    #       PVID = 1;
    #       EgressUntagged = 1;
    #     }
    #   ];
    # };
  };
}
