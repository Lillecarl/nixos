{
  lib,
  config,
  pkgs,
  ...
}:
let
  modName = "noshell";
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
    xdg.configFile."shell".source = lib.getExe pkgs.fish;
  };
}
