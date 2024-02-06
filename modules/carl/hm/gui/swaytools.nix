{ bp
, config
, lib
, pkgs
, self
, ...
}:
let
  cfg = config.carl.gui.swaytools;
  lockScript = bp (pkgs.writeShellScriptBin "swayLockScript" ''
    ${lib.getExe config.programs.rbw.package} lock
    ${lib.getExe pkgs.swaylock}
    ${lib.getExe config.programs.rbw.package} unlock
  '');
in
{
  options.carl.gui.swaytools = with lib; {
    enable = lib.mkOption {
      type = types.bool;
      default = config.carl.gui.enable;
    };
  };
  config = lib.mkIf cfg.enable {
    home.file."swayLockScript" = {
      target = ".local/bin/swayLockScript";
      source = lockScript;
    };

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

      systemdTarget = "hyprland-session.target";

      events = [
        { event = "before-sleep"; command = lockScript; }
        { event = "lock"; command = lockScript; }
      ];

      timeouts = [
        { timeout = 300; command = lockScript; }
        { timeout = 600; command = "${pkgs.hyprland}/bin/hyprctl dispatch dpms off"; }
      ];
    };
  };
}
