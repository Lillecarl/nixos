{
  lib,
  config,
  pkgs,
  ...
}:
let
  modName = "glab";
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
    xdg.configFile."glab-cli/hm_config.txt" = {
      text = ''
        check_update false
        display_hyperlinks true
      '';
      onChange = # bash
        ''
          while read -r line; do
            ${lib.getExe pkgs.glab} config set -g $line
          done < ~/.config/glab-cli/hm_config.txt
        '';
    };
  };
}
