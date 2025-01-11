{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    state = lib.mkOption {
      type = lib.types.str;
    };
  };
  config = {
    terraform.backend.s3 = config.lib.cfbucket config.state;
  };
}
