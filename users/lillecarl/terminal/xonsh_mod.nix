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
    enable = lib.mkEnableOption "Enable Xonsh shell";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.xonsh;
      defaultText = lib.literalExpression "pkgs.xonsh";
      description = "Package providing {command}`xonsh`.";
    };

    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "List of Python packages to add to Xonsh";
    };

    extraOptions = lib.mkOption {
      type = lib.types.lines;
      default = null;
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
          cfg.package.override ({ extraPackages = cfg.extraPackages; });
    in
    {
      home.packages = [
        package
      ];
      xdg.configFile."xonsh/rc.xsh" = {
        enable = cfg.extraOptions != null;
        text = cfg.extraOptions;
      };
    };
}
