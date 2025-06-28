{ lib, pkgs, config, ... }:
let
  modName = "audiovideo";
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
    home.packages = with pkgs; [
      easyeffects
      calf 
      qpwgraph
    ];
  };
}
