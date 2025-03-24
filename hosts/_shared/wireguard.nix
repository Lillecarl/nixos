{ lib, config, ... }:
let
  modName = "wireguard";
  cfg = config.ps.${modName};
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
  config = lib.mkIf cfg.enable {
    networking.wireguard = {
      enable = true;
    };
  };
}
