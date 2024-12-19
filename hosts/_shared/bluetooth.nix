{ lib, config, ... }:
let
  modName = "bluetooth";
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
    services.blueman.enable = true;

    hardware = {
      bluetooth = {
        enable = true;

        powerOnBoot = true;

        settings = {
          General = {
            Enable = "Source,Sink,Media,Socket";
          };
        };
      };
      enableRedistributableFirmware = true;
    };
  };
}
