_:
{
  home.sessionVariables = {
    SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/keyring/ssh";
  };
  services.gnome-keyring = {
    enable = true;
    components = [ "pkcs11" "secrets" "ssh" ];
  };

  # Start gnome-keyring as soon as user is logged in.
  systemd.user.services.gnome-keyring = {
    Install.WantedBy = [ "default.target" ];
    Unit.PartOf = [ "default.target" ];
  };
}
