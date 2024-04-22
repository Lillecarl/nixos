{ config
, lib
, ...
}:
let
  cfg = config.carl.gui.mako;
in
{
  options.carl.gui.mako = with lib; {
    enable = lib.mkOption {
      type = types.bool;
      default = config.carl.gui.enable;
    };
  };
  config = lib.mkIf cfg.enable {
    services.mako = {
      enable = true;

      anchor = "center";

      extraConfig = ''
        text-alignment=center
        [summary="Du presenterar för alla"]
        invisible=1
        [summary="Connection Established"]
        default-timeout=15000
      '';
    };
  };
}
