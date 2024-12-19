{ lib, config, ... }:
let
  modName = "earlyoom";
  cfg = config.ps.${modName};
in
{
  options.ps = {
    ${modName} = {
      enable = lib.mkOption {
        default = config.ps.workstation.enable;
        description = "Whether to enable ${modName}.";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    services.earlyoom = {
      enable = true;

      enableNotifications = true;
    };

    # Get notifications from the system bus
    services.systembus-notify.enable = true;
  };
}
