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
      package = pkgs.lix;
      settings = {
        allow-import-from-derivation = true;
        auto-allocate-uids = true;
        auto-optimise-store = true;
        builders-use-substitutes = true;
        keep-going = true;
        warn-dirty = false;

        system-features = [
          "recursive-nix"
          "uid-range"
        ];

        experimental-features = [
          "auto-allocate-uids"
          "cgroups"
          "nix-command"
          "ca-derivations"
          "flakes"
          "impure-derivations"
          "recursive-nix"
          "fetch-closure"
        ];

      };
      nixPath = [
        "nixpkgs=${inputs.nixpkgs.outPath}"
      ];
    };
  };
}
