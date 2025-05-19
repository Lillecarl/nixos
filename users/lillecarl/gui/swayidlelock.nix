{
  lib,
  config,
  pkgs,
  self,
  ...
}:
let
  lockScript = lib.getExe (
    pkgs.writeShellScriptBin "swayLockScript" ''
      ${config.programs.rbw.package}/bin/rbw lock
      ${lib.getExe pkgs.swaylock}
      ${config.programs.rbw.package}/bin/rbw unlock
    ''
  );
in
{
  config = lib.mkIf config.ps.gui.enable {
    catppuccin.swaylock.enable = false;

    programs.swaylock = {
      enable = true;

      settings = {
        daemonize = true;
        image = "${self}/resources/lockscreen.jpg";
        scaling = "center";
        color = "000000";
      };
    };

    services.swayidle = {
      enable = true;

      events = [
        {
          event = "before-sleep";
          command = lockScript;
        }
        {
          event = "lock";
          command = lockScript;
        }
      ];

      timeouts = [
        {
          timeout = 300;
          command = lockScript;
        }
        {
          timeout = 1800;
          command = "${lib.getExe pkgs.niri} msg action power-off-monitors";
        }
      ];
    };
  };
}
