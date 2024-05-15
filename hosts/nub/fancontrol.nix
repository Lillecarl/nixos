{ pkgs
, self
, lib
, ...
}:
let
  fanscript = pkgs.writers.writePython3Bin "fancontrol2"
    {
      libraries = with pkgs.python3.pkgs; [
        psutil
        plumbum
      ];
      flakeIgnore = [ "E265" ]; # E265 block comment should start with '# '
    }
    (builtins.readFile "${self}/scripts/fancontrol2.py");
in
{
  systemd.services.fancontrol = {
    enable = false;
    wantedBy = [ "multi-user.target" ];

    path = with pkgs; [
      lm_sensors # Read systems sensors
    ];

    serviceConfig = {
      ExecStart = lib.getExe fanscript;
      # Required to get log output from the service when in
      #Environment = "PYTHONUNBUFFERED=1";
    };
  };

}
