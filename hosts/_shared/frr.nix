{ lib, config, ... }:
let
  modName = "frr";
  cfg = config.ps.${modName};
in
{
  options.ps = {
    ${modName} = {
      enable = lib.mkOption {
        default = true;
        type = lib.types.bool;
        description = "Whether to enable ${modName}.";
      };
      isHub = lib.mkOption {
        default = false;
        type = lib.types.bool;
        description = "If we should listen to 10.44.33.0/24 or connect to 10.44.33.1";
      };
      ASN = lib.mkOption {
        type = lib.types.int;
        description = "ASN to use for this BGP instance";
      };
    };
  };
  config =
    let
      routeMaps = ''
        route-map home permit 10
          match ip address prefix-list home
        exit
        route-map 1918 permit 10
          match ip address prefix-list 1918
        exit
      '';
      prefixLists = ''
        ip prefix-list 1918 seq 10 permit 10.0.0.0/8      ge 8
        ip prefix-list 1918 seq 20 permit 172.16.0.0/12   ge 12
        ip prefix-list 1918 seq 30 permit 192.168.0.0/16  ge 16
        ip prefix-list 1918 seq 40 deny   0.0.0.0/0       le 32

        ip prefix-list home seq 10 permit 192.168.88.0/24 ge 24
        ip prefix-list home seq 20 deny   0.0.0.0/0       le 32
      '';
      hostSpecific =
        if config.networking.hostName == "shitbox" then
          ''
            neighbor 10.44.33.1 peer-group hub
            neighbor 192.168.88.1 remote-as external
            address-family ipv4 unicast
              redistribute connected
              neighbor spoke route-map home out
              neighbor spoke route-map 1918 in
              neighbor spoke soft-reconfiguration inbound

              neighbor 192.168.88.1 route-map 1918 out
              neighbor 192.168.88.1 route-map 1918 in
              neighbor 192.168.88.1 soft-reconfiguration inbound
            exit-address-family
          ''
        else if config.networking.hostName == "hetzner1" then
          ''
            bgp listen range 10.44.33.0/24 peer-group spoke
            address-family ipv4 unicast
              neighbor hub route-map 1918 out
              neighbor hub route-map 1918 in
              neighbor hub soft-reconfiguration inbound
            exit-address-family
          ''
        else
          '''';
      frrConfig = ''
        frr defaults datacenter

        ${prefixLists}
        ${routeMaps}

        router bgp ${toString cfg.ASN}
          neighbor spoke peer-group
          neighbor spoke remote-as external
          neighbor hub peer-group
          neighbor hub remote-as external
          ${hostSpecific}
        exit
        end
      '';
    in
    lib.mkIf cfg.enable {
      services.frr = {
        bgpd.enable = true;
        config = frrConfig;
      };
    };
}
