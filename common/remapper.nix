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
  cfg = config.carl;
in
{
  options.carl.remapper = {
    enable = lib.mkEnableOption "Enable remapper";
    debug = lib.mkEnableOption "Enable remapper debug";
    keyboardName = lib.mkOption {
      type = lib.types.str;
      #default = "AT Translated Set 2 keyboard";
      description = "Name of the keyboard to remap";
    };
  };
  config = {
    systemd.services.remapper = {
      description = "remapper";
      wantedBy = [ "multi-user.target" ];
      environment = {
        "INPUT_DEBUG" = if cfg.remapper.debug then "true" else "false";
        "INPUT_NAME" = cfg.remapper.keyboardName;
      };
      serviceConfig = {
        Type = "simple";
        ExecStart = wrapper;
        Restart = "always";
        RestartSec = "5";
        Nice = "-10";
      };
    };
  };
}
