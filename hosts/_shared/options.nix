{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.ps = {
    workstation = {
      enable = lib.mkOption {
        default = false;
        description = "Whether to enable workstation config.";
      };
    };
    server = {
      enable = lib.mkOption {
        default = false;
        description = "Whether to enable server config.";
      };
    };
  };
}
