{ pkgs
, lib
, config
, self
, ...
}:
let
  python = pkgs.python3.withPackages (ps: with ps; [ evdev ]);
  script = pkgs.writeScript "remapperd_wrapped" (
    builtins.readFile "${self}/scripts/remapper.py"
  );
  wrapper = pkgs.writers.writeFish "remapperd_wrapper" ''
    exec ${lib.getExe python} -u ${script}
  '';
in
{
  systemd.services.remapper = {
    description = "remapper";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = wrapper;
      Restart = "always";
      RestartSec = "5";
    };
  };
}
