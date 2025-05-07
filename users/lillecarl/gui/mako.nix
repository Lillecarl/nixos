{ lib, config, ... }:
{
  config = lib.mkIf config.ps.gui.enable {
    services.mako = {
      enable = true;

      settings = {
        anchor = "center";
        text-alignment = "center";
      };

      criteria = {
        "summary=\"Du presenterar för alla\"" = {
          invisible = 1;
        };
        "summary=\"Connection Established\"" = {
          default-timeout = 15000;
        };
      };
    };
  };
}
