{ config
, pkgs
, lib
, ...
}: rec
{
  # Kills KDE if it hangs on shutdown
  systemd.services.KWinKill = {
    wantedBy = [ "multi-user.target" ];

    script = "${pkgs.bashInteractive}/bin/sh -c \"true\"";
    preStop = ''
      ${pkgs.procps}/bin/pkill -KILL kwin_x11
      ${pkgs.procps}/bin/pkill -KILL zellij
    '';

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    stopIfChanged = false;
    restartIfChanged = false;
    reloadIfChanged = false;
  };
}
