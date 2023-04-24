{ config
, pkgs
, inputs
, ...
}: {
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    enableExtraSocket = true;
  };

  programs.gpg = {
    enable = true;

    mutableKeys = true;
    mutableTrust = true;
    homedir = "${config.xdg.dataHome}/gnupg";
  };
}
