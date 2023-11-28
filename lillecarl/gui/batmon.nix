{ self, pkgs, ... }:
let
  mkBinPath = builtins.map (path: "${path}/bin");
in
{
  systemd.user.services.batmon = {
    Unit = {
      Description = "Battery monitoring";
    };
    Service = {
      ExecSearchPath = mkBinPath [
        pkgs.libnotify
        (pkgs.python3.withPackages (ps: with ps; [
          plumbum
        ]))
      ];
      ExecStart = "${self}/scripts/batmon.py";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
