{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
let
  modName = "nodes";
  cfg = config.ps.${modName};
  node = config.ps.${modName}.node;
in
{
  options.ps =
    let
      nodeType = lib.types.submodule {
        options = {
          hostName = lib.mkOption {
            description = "Server name";
            type = lib.types.str;
            readOnly = true;
          };
          ipv4Addr = lib.mkOption {
            description = "Primary IPv4 IP";
            type = lib.types.str;
          };
          ipv6Addr = lib.mkOption {
            description = "Primary IPv6 IP";
            type = lib.types.str;
          };
          diskPath = lib.mkOption {
            description = "Local disk path";
            type = lib.types.str;
          };
          ifName = lib.mkOption {
            description = "WAN interface name";
            type = lib.types.str;
          };
          ASN = lib.mkOption {
            description = "BGP ASN";
            type = lib.types.either lib.types.int lib.types.str;
            apply = toString;
          };
        };
      };
    in
    {
      ${modName} = {
        nodes = lib.mkOption {
          description = "Attrset of all OS configurations";
          type = lib.types.attrsOf nodeType;
          apply = lib.mapAttrs (name: value: value // { hostName = name; });
        };
        node = lib.mkOption {
          description = "Attrset of current OS configuration";
          type = nodeType;
        };
      };
    };
  config = {
    ps = {
      nodes.node = lib.getAttr config.networking.hostName cfg.nodes;
      k3s = {
        nodeIPs = [
          node.ipv4Addr
          node.ipv6Addr
        ];
        externalNodeIPs = [
          node.ipv4Addr
          node.ipv6Addr
        ];
      };
      networking.ifName = node.ifName;
      networking.addresses = [
        (node.ipv4Addr)
        (node.ipv6Addr)
      ];
    };
  };
}
