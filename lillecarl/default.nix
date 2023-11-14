{ ... }:
{
  nixpkgs = {
    config.allowUnfree = true;
  };

  xdg = {
    enable = true;
  };

  # HM stuff
  home.username = "lillecarl";
  home.homeDirectory = "/home/lillecarl";
  home.stateVersion = "22.05";
  home.enableNixpkgsReleaseCheck = true;
  news.display = "silent";
  programs.home-manager.enable = true;

  # Use experimental sd-switch to determine which systemd user units
  # to restart, do it automatically.
  systemd.user.startServices = "sd-switch";
  # No user services require more than 10 sec to start.
  systemd.user.servicesStartTimeoutMs = 10000;
}
