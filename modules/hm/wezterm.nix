{ config
, lib
, ...
}:
let
  cfg = config.programs.wezterm;
in
{
  options = {
    programs.wezterm = {
      systemdTarget = lib.mkOption {
        type = lib.types.str;
        default = "";
        example = "sway-session.target";
        description = ''
          Systemd target to bind to.
        '';
      };
    };
  };

  config = lib.mkIf (cfg.enable && cfg.systemdTarget != "") {
    systemd.user.services.wezterm-mux-server = {
      Unit = {
        X-SwitchMethod = "restart";
        X-ConfigHash = builtins.hashString "md5" cfg.extraConfig;
        Description = "WezTerm Multiplexer Server";
      };
      Service = {
        ExecStart = "${cfg.package}/bin/wezterm-mux-server";
        Restart = "always";
        RestartSec = "5";
      };
      Install = {
        WantedBy = [ cfg.systemdTarget ];
      };
    };
  };
}
