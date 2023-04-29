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
            if not __xonsh__.env.get('__NIXOS_SET_ENVIRONMENT_DONE'):
              # The NixOS environment and thereby also $PATH
              # haven't been fully set up at this point. But
              # `source-bash` below requires `bash` to be on $PATH,
              # so add an entry with bash's location:
              $PATH.add('${pkgs.bash}')
            
              # Stash xonsh's ls alias, so that we don't get a collision
              # with Bash's ls alias from environment.shellAliases:
              _ls_alias = aliases.pop('ls', None)
            
              # Source the NixOS environment config.
              source-bash "${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh"
            
              # Restore xonsh's ls alias, overriding that from Bash (if any).
              if _ls_alias is not None:
                  aliases['ls'] = _ls_alias
              del _ls_alias
          ''
          (lib.optionalString cfg.enableBashCompletion ''
            source-bash ${pkgs.bash-completion}/etc/profile.d/bash_completion.sh"
          '')
          cfg.extraConfig
        ]);
        executable = true;
      };
    };
  };
}
