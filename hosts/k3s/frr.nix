{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
let
  modName = "frr";
  cfg = config.ps.${modName};
  nodes = config.ps.nodes;
in
{
  options.ps = {
    ${modName} = {
      enable = lib.mkOption {
        default = true;
        description = "Whether to enable ${modName}.";
      };
    };
  };
  config =
    let
      peerLines = lib.pipe nodes.nodes [
        (x: lib.filterAttrs (n: v: v.ASN != nodes.node.ASN) x)
        (x: lib.mapAttrs (n: v: " neighbor ${v.ipv4Addr} peer-group fabric") x)
        (x: lib.attrValues x)
        (x: lib.concatStringsSep "\n" x)
      ];
    in
    lib.mkIf cfg.enable {
      services.frr = {
        bgpd.enable = true;

        config = # frr
          ''
            frr version 10.3.1
            frr defaults datacenter
            hostname ${config.networking.hostName}
            log syslog informational
            service integrated-vtysh-config
            !
            router bgp ${nodes.node.ASN}
             bgp router-id ${nodes.node.ipv4Addr}
             bgp cluster-id ${nodes.node.ipv4Addr}
             neighbor fabric peer-group
             neighbor fabric remote-as external
             neighbor fabric capability extended-nexthop
            ${peerLines}
             !
             address-family ipv4 unicast
              redistribute connected
              neighbor fabric activate
             exit-address-family
             !
             address-family l2vpn evpn
              neighbor fabric activate
              neighbor fabric route-reflector-client
              advertise-all-vni
             exit-address-family
            !
          '';
      };
    };
}
