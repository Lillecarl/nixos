{ lib, config, ... }:
let
  modName = "television";
  cfg = config.ps.${modName};
in
{
  options.ps = {
    ${modName} = {
      enable = lib.mkOption {
        default = config.ps.terminal.enable;
        description = "Whether to enable ${modName}.";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    programs.television = {
      enable = true;
      enableFishIntegration = config.ps.fish.enable;

      settings = {
        ui = {
          theme = "catppuccin";
          input_bar_position = "bottom";
        };
      };
    };
  };
}
