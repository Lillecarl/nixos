{ lib, ... }:
{
  options.ps = {
    # Labels from Hetzner
    labels = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
    };
    # Something, just dump shit in here
    smth = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.oneOf [
          lib.types.attrs
          lib.types.str
          lib.types.bool
          lib.types.list
        ]
      );
    };
  };
}
