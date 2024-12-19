{
  lib,
  config,
  inputs,
  ...
}:
let
  modName = "stylix";
  cfg = config.ps.${modName};
in
{
  imports = [
    inputs.stylix.nixosModules.stylix
  ];
  options.ps = {
    ${modName} = {
      enable = lib.mkOption {
        default = config.ps.workstation.enable;
        description = "Whether to enable ${modName}.";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    stylix = {
      homeManagerIntegration.autoImport = false;

      targets = {
        chromium.enable = true;
      };
    };
  };
}
