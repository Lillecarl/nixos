{ config
, ...
}: {
  services.gpg-agent = {
    enable = true;
    enableSshSupport = false; # gnome-keyring
    enableExtraSocket = true;
  };

  programs.gpg = {
    enable = true;

    mutableKeys = true;
    mutableTrust = true;
    homedir = "${config.xdg.dataHome}/gnupg";
  };
}
