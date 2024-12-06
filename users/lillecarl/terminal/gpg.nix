{
  config,
  pkgs,
  ...
}:
{
  services.gpg-agent = {
    enable = true;
    enableSshSupport = false; # gnome-keyring
    enableExtraSocket = true;
    pinentryPackage = pkgs.pinentry-qt;
    grabKeyboardAndMouse = false;
  };

  programs.gpg = {
    enable = true;

    mutableKeys = true;
    mutableTrust = true;
    homedir = "${config.xdg.dataHome}/gnupg";
  };
}
