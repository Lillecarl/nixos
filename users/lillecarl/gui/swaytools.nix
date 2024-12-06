{
  lib,
  config,
  pkgs,
  self,
  inputs,
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
    home.file."swayLockScript" = {
      target = ".local/bin/swayLockScript";
      source = lockScript;
    };

    programs.swaylock = {
      enable = true;
      catppuccin.enable = false;

      settings = {
        daemonize = true;
        image = "${self}/resources/lockscreen.jpg";
        scaling = "center";
        color = "000000";
      };
    };

    services.swayidle = {
      enable = true;

      systemdTarget = config.ps.gui.systemdTarget;

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
      ];
    };

    systemd.user.services.swaybg = {
      Unit = {
        Description = "Sway background image daemon";
        PartOf = [ config.ps.gui.systemdTarget ];
      };

      Service = {
        ExecStart = "${lib.getExe pkgs.swaybg} --image ${inputs.nixos-artwork}/wallpapers/nix-wallpaper-watersplash.png";
      };
      Install = {
        WantedBy = [ config.ps.gui.systemdTarget ];
      };
    };
  };
}
