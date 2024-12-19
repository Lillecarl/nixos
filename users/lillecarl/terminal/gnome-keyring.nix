{ lib, config, ... }:
let
  modName = "gnome-keyring";
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
    home.sessionVariables = {
      SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/keyring/ssh";
    };
    services.gnome-keyring = {
      enable = true;
      components = [
        "pkcs11"
        "secrets"
        "ssh"
      ];
    };

    # Start gnome-keyring as soon as user is logged in.
    systemd.user.services.gnome-keyring = {
      Install.WantedBy = lib.mkForce [ "default.target" ];
      Unit.PartOf = lib.mkForce [ "default.target" ];
    };
  };
}
