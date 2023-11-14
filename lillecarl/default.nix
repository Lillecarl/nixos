{ pkgs
, lib
, flakeloc
, config
, ...
}:
let
  dot_path = "${flakeloc}/lillecarl/dotfiles/";
  dot_paths = lib.filesystem.listFilesRecursive (builtins.toPath dot_path);
  dot_strings = builtins.map (x: builtins.toString x) dot_paths;
  dot_prefixDeleted = builtins.map (x: builtins.replaceStrings [ dot_path ] [ "" ] x) dot_strings;
  dotfile_rootFiltered = builtins.filter (path: (builtins.match ".*\/.*" path) != null) dot_prefixDeleted;
  dotfile_outOfStoreLinked = lib.attrsets.genAttrs dotfile_rootFiltered (name: {
    source = (config.lib.file.mkOutOfStoreSymlink (dot_path + name));
  });
in
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

  home.file = dotfile_outOfStoreLinked;
}
