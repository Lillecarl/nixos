{
  lib,
  config,
  pkgs,
  self,
  ...
}:
let
  modName = "remapper";
  cfg = config.ps.${modName};

  python = pkgs.python3.withPackages (
    ps: with ps; [
      evdev
      sh
    ]
  );
  script = pkgs.writeScript "remapperd_wrapped" (builtins.readFile "${self}/scripts/remapper.py");
  wrapper = pkgs.writers.writeFish "remapperd_wrapper" ''
    exec ${lib.getExe python} -u ${script}
  '';
in
{
  options.ps = {
    ${modName} = {
      enable = lib.mkOption {
        default = config.ps.workstation.enable;
        description = "Whether to enable ${modName}.";
      };
      debug = lib.mkEnableOption "Enable remapper debug";
      keyboardName = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Name of the keyboard to remap";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.services.remapper = {
      description = "remapper";
      wantedBy = [ "multi-user.target" ];
      environment = {
        "INPUT_DEBUG" = if cfg.remapper.debug then "true" else "false";
        "INPUT_NAME" = cfg.remapper.keyboardName;
        "HEADSET_XML_PATH" = ../../resources/logitech-g933.xml;
      };
      path = [
        pkgs.ddcutil
        pkgs.libvirt
      ];
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
