{ pkgs
, lib
, ...
}:
{
  xdg.configFile."glab-cli/hm_config.txt" = {
    text = ''
      check_update false
      display_hyperlinks true
    '';
    onChange = /* bash */ ''
      while read -r line; do
        ${lib.getExe pkgs.glab} config set -g $line
      done < ~/.config/glab-cli/hm_config.txt
    '';
  };
}
