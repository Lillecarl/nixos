{ config
, lib
, ...
}:
{
  options.carl = with lib; {
    gui = {
      enable = mkEnableOption "Enable the Carl GUI";
      systemdTarget = mkOption {
        type = types.str;
        default = "";
        description = "The systemd target to bind GUI services to";
      };
    };
    bluetooth = {
      enable = lib.mkEnableOption "Enable Bluetooth";
    };
  };
}
