{ config
, pkgs
, ...
}: {
  home = {
    file.".local/bin/.keep".text = "";

    inherit (config.pam) sessionVariables;
  };

  xdg.enable = true;

  programs = {
    man = {
      enable = true;
      generateCaches = false;
    };

    zellij = {
      enable = true;

      settings = { };
    };

    rbw = {
      enable = true;
      settings = {
        email = "bitwarden@lillecarl.com";
        pinentry = pkgs.pinentry-qt;
        sync_interval = 300;
        lock_timeout = 3600 * 24;
      };
    };
  };
}
