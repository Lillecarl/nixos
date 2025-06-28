{ lib, config, ... }:
let
  modName = "zellij";
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
    programs.zellij = {
      enable = true;
      # enableFishIntegration = true;
      # exitShellOnExit = true;
    };
  };
}
