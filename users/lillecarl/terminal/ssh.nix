{ lib, config, ... }:
let
  modName = "ssh";
  cfg = config.ps.${modName};
in
{
  options.ps = {
    ${modName} = {
      enable = lib.mkOption {
        default = config.ps.terminal.enable;
        description = "Whether to enable ${modName}.";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    programs.ssh = lib.mkIf config.ps.terminal.enable {
      enable = true;

      forwardAgent = false;

      serverAliveInterval = 10;
      serverAliveCountMax = 6;

      extraConfig = ''
        ConnectTimeout 5
        StrictHostKeyChecking accept-new
      '';
    };
  };
}
