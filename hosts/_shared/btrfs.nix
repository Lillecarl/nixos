{ lib, config, ... }:
let
  modName = "btrfs";
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
    services.btrfs.autoScrub = {
      enable = true;
      fileSystems = [ "/" ];
      interval = "weekly";
    };
  };
}
