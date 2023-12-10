{ pkgs
, bp
, ...
}:
{
  systemd.services = {
    UpdateFlatpaks = {
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      startAt = "daily";

      path = with pkgs; [ flatpak ];

      serviceConfig = {
        Type = "oneshot";
      };

      script = "${bp pkgs.flatpak} --system update -y";
    };
  };

  systemd.user.services.UpdateFlatpaks = {
    path = with pkgs; [ flatpak ];

    serviceConfig = {
      Type = "oneshot";
    };

    script = "${bp pkgs.flatpak} --user update -y";
  };
}
