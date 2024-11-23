{ lib, ... }:
{
  options.ps = {
    terminal = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
      nerdfonts = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
    };
  };
}
