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
      address = cfg.addresses;
      routes = [
        {
          Gateway = "fe80::1";
          GatewayOnLink = true;
        }
      ];
    };
  };
}
