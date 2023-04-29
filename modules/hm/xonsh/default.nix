{ config, pkgs, lib, ... }:
let
  cfg = config.programs.xonsh;
in
{
  options.programs.xonsh = {
    enable = lib.mkEnableOption "Enable xonsh shell";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.xonsh;
    };
    rcDir = lib.mkOption {
      type = lib.types.path;
      default = builtins.null;
      description = lib.mdDoc ''
        Directory to pull xonsh rc files from
      '';
    };
    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = lib.mdDoc ''
        Directory to pull xonsh rc files from
      '';
    };
    enableBashCompletion = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Enable bash completion engine
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.file = {
      ".config/xonsh/rc.d" = lib.mkIf (!builtins.isNull cfg.rcDir) {
        source = cfg.rcDir;
        recursive = true;
        executable = true;
      };
      ".config/xonsh/rc.xsh" = {
        text = lib.concatStringsSep "\n" ([
          ''
            #! ${cfg.package}/bin/xonsh
            $PATH.add('${pkgs.bash}')

            # Source the HM environment config.
            source-bash --suppress-skip-message "${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh"
          ''
          (lib.optionalString cfg.enableBashCompletion ''
            source-bash --suppress-skip-message "${pkgs.bash-completion}/etc/profile.d/bash_completion.sh"
          '')
          cfg.extraConfig
        ]);
        executable = true;
      };
    };
  };
}
