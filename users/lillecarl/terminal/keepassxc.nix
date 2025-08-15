{ lib, config, ... }:
let
  modName = "keepassxc";
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
    # Force disable gnome-keyring so Keepass can store "system secrets"
    services.gnome-keyring.enable = lib.mkForce false;
    # Enable ssh-agent, keepass integrates with it
    services.ssh-agent.enable = true;
    # Set ssh-agent auth socket path to where ssh-agent creates it
    home.sessionVariables.SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/ssh-agent";
    # Enable keepassxc
    programs.keepassxc.enable = true;
  };
}
