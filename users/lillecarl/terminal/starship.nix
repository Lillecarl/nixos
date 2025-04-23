{ lib, config, ... }:
let
  modName = "starship";
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
    programs.starship = {
      enable = true;
      settings = lib.mkForce {};
    };
  };
}
