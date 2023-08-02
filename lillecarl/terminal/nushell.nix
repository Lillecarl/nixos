{ config
, pkgs
, inputs
, ...
}: {
  programs.nushell = {
    enable = true;

    configFile.text = ''
      $env.config = {
        edit_mode: vi
        # direnv integration
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
}
