{ lib
, pkgs
, flakeloc
, self
, config
, nixosConfig
, inputs
, ...
}:
{
  imports = [
    ./dotfiles.nix
    ./gui
    ./options.nix
    ./terminal
  ];

  programs.home-manager.enable = true;

  # Reference flake inputs in xdg datadir. Prevents Nix collecting flake inputs as garbage.
  # I find it weird this isn't the default behaviour
  xdg.dataFile = lib.mapAttrs' (key: val: { name = "flakeinputs/${key}"; value = { source = "${val}"; }; }) inputs;

  xdg = {
    enable = true;
    userDirs.createDirectories = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        "inode/directory" = "pcmanfm.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
        "x-scheme-handler/mailto" = "firefox.desktop";
        "x-scheme-handler/about" = "firefox.desktop";
        "x-scheme-handler/slack" = "slack.desktop";
        "x-scheme-handler/element" = "element.desktop";
        "text/html" = "firefox.desktop";
        "text/plain" = "neovide.desktop";
      };
    };
  };

  # HM stuff
  home = {
    username = "lillecarl";
    homeDirectory = "/home/lillecarl";
    stateVersion = nixosConfig.system.stateVersion or "24.05";
    enableNixpkgsReleaseCheck = true;
  };
  # Don't display HM news.
  news.display = "silent";

  # Use experimental sd-switch to determine which systemd user units
  # to restart, do it automatically.
  systemd.user = {
    startServices = "sd-switch";
    # No user services require more than 10 sec to start.
    servicesStartTimeoutMs = 10000;
  };
}
