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

  backgroundImage = pkgs.fetchurl {
    url = "https://github.com/NixOS/nixos-artwork/blob/master/wallpapers/nix-wallpaper-watersplash.png?raw=true";
    sha256 = "sha256-6Gdjzq3hTvUH7GeZmZnf+aOQruFxReUNEryAvJSgycQ=";
  };
in
{
  config = lib.mkIf config.ps.gui.enable {
    catppuccin.swaylock.enable = false;

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
        ExecStart = "${lib.getExe pkgs.swaybg} --image ${backgroundImage}";
      };
      Install = {
        WantedBy = [ config.ps.gui.systemdTarget ];
      };
    };
  };
}
