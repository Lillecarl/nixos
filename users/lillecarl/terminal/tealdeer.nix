{ lib, config, ... }:
let
  modName = "tealdeer";
  cfg = config.ps.${modName};
in
{
  options.ps = {
    ${modName} = {
      enable = lib.mkOption {
        default = config.ps.terminal.mode == "fat";
        description = "Whether to enable ${modName}.";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    programs.tealdeer = {
      enable = true;

      settings = {
        display = {
          compact = false;
          use_pager = false;
        };

        updates = {
          auto_update = true;
          auto_update_interval_hours = 168;
        };
      };
    };
  };
}
