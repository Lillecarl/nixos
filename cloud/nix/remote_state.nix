{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    remoteStates = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
  };
  config = lib.mkIf (config.remoteStates != [ ]) {
    data.terraform_remote_state = builtins.listToAttrs (
      builtins.map (x: {
        name = x;
        value = {
          backend = "s3";
          config = config.lib.cfbucket x;
        };
      }) config.remoteStates
    );
    locals.rs = builtins.listToAttrs (
      builtins.map (x: {
        name = x;
        value = lib.tfRef "data.terraform_remote_state.${x}.outputs";
      }) config.remoteStates
    );
  };
}
