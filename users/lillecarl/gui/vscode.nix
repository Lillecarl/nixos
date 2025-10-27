{ lib, config, pkgs, ... }:
let
  modName = "vscode";
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
    catppuccin.vscode.profiles.default.enable = false;
    programs.vscode = {
      enable = true;
      package = pkgs.vscode.fhsWithPackages (ps: with ps; [
        bash
      ]);
    };
  };
}
