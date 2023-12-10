_:
{
  home.sessionVariables = {
    SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/keyring/ssh";
  };
  services.gnome-keyring = {
    enable = true;
    components = [ "pkcs11" "secrets" "ssh" ];
  };
}
