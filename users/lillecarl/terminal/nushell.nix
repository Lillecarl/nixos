{ lib, config, ... }:
let
  modName = "nushell";
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
    programs.starship.enableNushellIntegration = true;
    programs.direnv.enableNushellIntegration = true;

    programs.nushell = {
      enable = true;

      configFile.text = ''
        $env.config = {
          edit_mode: vi
          show_banner: false
          hooks: {
            pre_prompt: [{
              code: "
                let direnv = (direnv export json | from json)
                let direnv = if ($direnv | length) == 1 { $direnv } else { {} }
                $direnv | load-env
              "
            }]
          }
        }
      '';
    };
  };
}
