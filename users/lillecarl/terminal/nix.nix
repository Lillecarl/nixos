{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
let
  modName = "nix";
  cfg = config.ps.${modName};
in
{
  options.ps = {
    ${modName} = {
      enable = lib.mkOption {
        default = true;
        description = "Whether to enable ${modName}.";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    nix = {
      package = pkgs.nixVersions.latest;
      settings = {
        warn-dirty = false;
        keep-going = true;
      };
      # registry = {
      #   nixpkgs = {
      #     flake = inputs.nixpkgs;
      #   };
      # };
    };
  };
}
