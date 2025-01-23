{
  lib,
  ...
}:
{
  options.kv = lib.mkOption {
    type = lib.types.attrs;
    default = {};
  };
}
