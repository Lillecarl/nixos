{ lib, config, ... }:
{
  config = lib.mkIf config.ps.gui.enable {
    services.cliphist = {
      enable = true;
      extraOptions = [
        "-max-items"
        "500"
      ];
    };
  };
}
