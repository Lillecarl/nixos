{ lib, ... }:
{
  options.ps.labels = lib.mkOption {
    type = lib.types.attrsOf lib.types.str;
  };
}
