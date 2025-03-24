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
  config = lib.mkIf cfg.enable {
    services.frr = {
      bgpd.enable = true;
      config = if cfg.isHub then ''
        router bgp ${toString cfg.ASN}
          neighbor spoke peer-group
          neighbor spoke remote-as external
          neighbor 10.44.33.0/24 interface peer-group spoke
      '' else ''
        router bgp ${toString cfg.ASN}
          neighbor hub peer-group
          neighbor hub remote-as external
          neighbor 10.44.33.1 peer-group hub
      '';
    };
  };
}
