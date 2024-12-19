{
  lib,
  config,
  pkgs,
  ...
}:
let
  modName = "krew";
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
    home.packages = [
      pkgs.krew
    ];

    xdg.configFile."krew/bin/kubectl-krew" = {
      source = lib.getExe pkgs.krew;
      executable = true;
    };
  };
}
