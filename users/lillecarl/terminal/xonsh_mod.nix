{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.xonsh;
in
{
  meta.maintainers = [ lib.maintainers.lillecarl ];

  options.programs.xonsh = {
    enable = lib.mkEnableOption "xonsh";

    package = lib.mkPackageOption pkgs "xonsh" { };

    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "List of Python packages to add to Xonsh";
    };

    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Lines to add to Xonsh RC file";
    };
  };

  config =
    let
      # Allow advanced users to just supply their own Xonsh package.
      # Allow regular users to add Python packages to Xonsh through module.
      package =
        if cfg.extraPackages == [ ] then
          cfg.package
        else
          cfg.package.override { extraPackages = cfg.extraPackages; };
    in
    lib.mkIf cfg.enable {
      home.packages = [
        package
      ];
      xdg.configFile."xonsh/rc.xsh" = {
        text = cfg.extraConfig;
      };
    };
}
