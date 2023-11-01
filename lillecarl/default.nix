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
}
