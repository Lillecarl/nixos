{ lib, config, pkgs, inputs, ... }:
{
  config = lib.mkIf config.ps.terminal.enable {
    nix = {
      package = pkgs.nixVersions.latest;
      settings = {
        warn-dirty = false;
      };
      registry = {
        nixpkgs = { flake = inputs.nixpkgs; };
      };
    };
  };
}
