{
  lib,
  config,
  pkgs,
  ...
}:
let
  modName = "gpg";
  cfg = config.ps.${modName};
in
{
  options.ps = {
    ${modName} = {
      enable = lib.mkOption {
        default = config.ps.terminal.mode == "fat";
        description = "Whether to enable ${modName}.";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    services.gpg-agent = {
      enable = true;
      enableSshSupport = false; # ssh-agent + keepassxc
      enableExtraSocket = true;
      #pinentryPackage = pkgs.pinentry-qt;
      grabKeyboardAndMouse = false;
    };

    programs.gpg = {
      enable = true;

      mutableKeys = true;
      mutableTrust = true;
      homedir = "${config.xdg.dataHome}/gnupg";
    };
  };
}
