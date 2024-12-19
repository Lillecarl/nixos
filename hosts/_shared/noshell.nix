{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
let
  modName = "noshell";
  cfg = config.ps.${modName};
in
{
  imports = [ inputs.noshell.nixosModules.default ];

  options.ps = {
    ${modName} = {
      enable = lib.mkOption {
        default = true;
        description = "Whether to enable ${modName}.";
      };
    };
  };
  config = lib.mkIf cfg.enable {

    programs.noshell = {
      enable = true;
    };

    users.users.root = {
      shell = pkgs.bashInteractive;
    };
  };
}
