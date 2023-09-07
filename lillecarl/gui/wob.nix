{ pkgs
, ...
}:
{
  systemd.user.services.wob = {
    Unit = {
      Description = "A lightweight overlay volume/backlight/progress/anything bar for Wayland";
      Documentation = "man:wob(1)";
      PartOf = [ "hyprland-session.target" ];
      After = [ "hyprland-session.target" ];
      ConditionEnvironment = "WAYLAND_DISPLAY";
    };
    Service = {
      StandardInput = "socket";
      ExecStart = "${pkgs.wob}/bin/wob";
    };

    Install = {
      WantedBy = [ "hyprland-session.target" ];
    };
  };

  systemd.user.sockets.wob = {
    Socket = {
      ListenFIFO = "%t/wob.sock";
      SocketMode = "0600";
      RemoveOnStop = "on";
      # If wob exits on invalid input, systemd should NOT shove following input right back into it after it restarts
      FlushPending = "yes";
    };

    Install = {
      WantedBy = [ "sockets.target" ];
    };
  };
}
