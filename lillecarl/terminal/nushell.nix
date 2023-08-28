{ config
, pkgs
, inputs
, ...
}: {
  programs.nushell = {
    enable = true;

    configFile.text = ''
      $env.SHELL = "nu"
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
}
