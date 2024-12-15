{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.ps = {
    server = {
      enable = lib.mkOption {
        default = false;
        description = "Whether to enable server config.";
      };
    };
  };
}
