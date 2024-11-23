{ lib, config, ... }:
{
  config = lib.mkIf config.ps.gui.enable {
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
