{ config, pkgs, ... }:
rec
{
  environment.etc."keyd/default.conf".text = ''
    [ids]
    *

    [main]

    capslock = esc
  '';

  systemd.services.keyd = {
    wantedBy = [ "multi-user.target" ];
    after = [ "multi-user.target" ];

    script = "${pkgs.keyd}/bin/keyd";

    restartTriggers = [ environment.etc."keyd/default.conf".text ];
  };

  users.groups = {
    keyd = {};
  };
}
