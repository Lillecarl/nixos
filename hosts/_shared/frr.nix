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
      config = ''
        frr defaults datacenter
        router bgp ${toString cfg.ASN}
          neighbor spoke peer-group
          neighbor spoke remote-as external
          neighbor hub peer-group
          neighbor hub remote-as external
          ${
            if cfg.isHub then
              ''
                bgp listen range 10.44.33.0/24 interface peer-group spoke
              ''
            else
              ''
                neighbor 10.44.33.1 peer-group hub
              ''
          }
      '';
    };
  };
}
