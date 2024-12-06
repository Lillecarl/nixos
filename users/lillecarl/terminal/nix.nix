{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
{
  config = lib.mkIf config.ps.terminal.enable {
    nix = {
      package = pkgs.nixVersions.latest;
      settings = {
        warn-dirty = false;
        keep-going = true;
      };
      registry = {
        nixpkgs = {
          flake = inputs.nixpkgs;
        };
      };
    };
  };
}
