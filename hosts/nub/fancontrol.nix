{ pkgs
, self
, ...
}:
let
  fanpy = (pkgs.python3.withPackages (ps: with ps; [
    psutil # CPU usage
    plumbum # Shell commands
  ]));
in
{
  systemd.services.fancontrol = {
    wantedBy = [ "multi-user.target" ];

    path = with pkgs; [
      lm_sensors # Read systems sensors
    ];

    script = ''
      ${fanpy}/bin/python3 -u ${self}/scripts/fancontrol2.py
    '';
  };

}
