{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.carl.gui.qutebrowser;
in
{
  options.carl.gui.qutebrowser = with lib; {
    enable = lib.mkOption {
      type = types.bool;
      default = config.carl.gui.enable;
    };
  };
  config = lib.mkIf cfg.enable {
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
