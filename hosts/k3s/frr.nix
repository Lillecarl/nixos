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
      filteredNodes = lib.filterAttrs (n: v: v.ASN != nodes.node.ASN) nodes.nodes;
    in
    lib.mkIf cfg.enable {
      networking.firewall.allowedTCPPorts = [ 179 ];
      networking.firewall.allowedUDPPorts = [ 4789 ];
      services.frr = {
        bgpd.enable = true;
        bfdd.enable = false;

        configFile = pkgs.writeSaneJinja2 {
          name = "frr-config";
          variables = {
            inherit (config.networking) hostName;
            inherit (nodes.node) ASN ipv4Addr;
            inherit filteredNodes;
          };
          template = ''
            frr version 10.3.1
            frr defaults datacenter
            hostname {{ hostName }}
            log syslog informational
            service integrated-vtysh-config
            !
            route-map ALLOW-ALL permit 10
            !
            router bgp {{ ASN }}
             bgp router-id {{ ipv4Addr }}
             ! bgp cluster-id {{ ipv4Addr }}
             neighbor fabric peer-group
             neighbor fabric remote-as external
             neighbor fabric ebgp-multihop 10
             neighbor fabric capability extended-nexthop
             neighbor fabric soft-reconfiguration inbound
             neighbor fabric update-source {{ ipv4Addr }}
             neighbor fabric capability dynamic
             neighbor fabric timers 3 9
             no neighbor underlay capability extended-nexthop
             {% for key, value in filteredNodes.items() %}
             neighbor {{ value. ipv4Addr }} peer-group fabric
             {% endfor %}
             !
             address-family ipv4 unicast
              neighbor fabric activate
              neighbor fabric route-map ALLOW-ALL in
              neighbor fabric route-map ALLOW-ALL out
              redistribute connected
              redistribute static
             exit-address-family
             !
             address-family l2vpn evpn
              neighbor fabric activate
              neighbor fabric route-map ALLOW-ALL in
              neighbor fabric route-map ALLOW-ALL out
              advertise-all-vni
              advertise-svi-ip
              advertise ipv4 unicast
             exit-address-family
            !
          '';
        };
      };
    };
}
