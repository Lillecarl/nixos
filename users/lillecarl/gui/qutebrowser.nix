{ lib, config, pkgs, ... }:
{
  config = lib.mkIf config.ps.gui.enable {
    home.packages = [
      pkgs.keyutils
      pkgs.bitwarden-cli
    ];
    programs.qutebrowser = {
      enable = true;
      searchEngines = {
        DEFAULT = "https://kagi.com/search?q={}";
      };
      extraConfig = /* python */ ''
        config.source('linked.py')
      '';
    };
  };
}
