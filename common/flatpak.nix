{ config
, pkgs
, lib
, ...
}: rec
{
  systemd.services = {
    UpdateFlatpaks = rec {
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      startAt = "daily";

      path = with pkgs; [ flatpak ];

      serviceConfig = {
        Type = "oneshot";
      };

      script = "${pkgs.flatpak}/bin/flatpak --system update -y";
    };
  };

  systemd.user.services.UpdateFlatpaks = {
    path = with pkgs; [ flatpak ];

    serviceConfig = {
      Type = "oneshot";
    };

    script = "${pkgs.flatpak}/bin/flatpak --user update -y";
  };
}
