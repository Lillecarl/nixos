{ config
, lib
, pkgs
, nixosConfig
, ...
}:
let
  cfg = config.carl.thinkpad;
in
{
  options.carl.thinkpad = with lib; {
    enable = mkEnableOption "Enable ThinkPad support";
  };
  config = lib.mkIf cfg.enable {
    systemd.user.services.miclight =
      let
        dep = "pipewire-pulse.service";
      in
      lib.mkIf nixosConfig.services.pipewire.enable or false
        {
          Unit = {
            Description = "Mutes microphone and turns off light";
            PartOf = [ dep ];
            After = [ dep ];
          };

          Service = {
            Type = "oneshot";
            ExecStart = "${pkgs.miconoff} 1";
          };

          Install = { WantedBy = [ dep ]; };
        };
  };
}
