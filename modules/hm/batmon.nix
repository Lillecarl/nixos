{ config
, pkgs
, lib
, self
, ...
}:
let
  cfg = config.carl.terminal.batmon;
  mkBinPath = builtins.map (path: "${path}/bin");
in
{
  options.carl.terminal.batmon = with lib; {
    enable = lib.mkOption {
      type = types.bool;
      default = config.carl.thinkpad.enable;
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.user.services.batmon = {
      Unit = {
        Description = "Battery monitoring";
      };
      Service = {
        ExecSearchPath = mkBinPath [
          pkgs.libnotify
          (pkgs.python3.withPackages (ps: with ps; [
            plumbum
          ]))
        ];
        ExecStart = pkgs.writeScript
          "batmon"
          (builtins.readFile "${self}/scripts/batmon.py");
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
