{ config, pkgs, inputs, ... }:
{
  programs.nushell = {
    enable = true;

    configFile.text = ''
      let-env config = {
        edit_mode: vi
      }
    '';
  };
}
