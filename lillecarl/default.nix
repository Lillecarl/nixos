{ lib
, pkgs
, flakeloc
, self
, config
, nixosConfig
, ...
}:
let
  sub_path = "lillecarl/dotfiles";
  dot_path_real = "${flakeloc}/${sub_path}";
  dot_path_store = "${self}/${sub_path}";
  dot_paths = lib.filesystem.listFilesRecursive dot_path_store;
  dot_prefixDeleted = builtins.map (x: builtins.replaceStrings [ "${dot_path_store}/" ] [ "" ] x) dot_paths;

  fromTo = builtins.map
    (name: {
      src = "${dot_path_real}/${name}";
      dst = "${config.home.homeDirectory}/${name}";
    })
    dot_prefixDeleted;
in
{
  nixpkgs.config.allowUnfree = true;
  programs.home-manager.enable = true;

  xdg = {
    enable = true;
    userDirs.createDirectories = true;
  };

  # HM stuff
  home = {
    username = "lillecarl";
    homeDirectory = "/home/lillecarl";
    stateVersion = nixosConfig.system.stateVersion or "24.05";
    enableNixpkgsReleaseCheck = true;
    file = {
      ".local/linkstate" = {
        text = builtins.toJSON fromTo;
        onChange =
          let
            uglinker = pkgs.writers.writePython3 "uglinker"
              {
                libraries = [ pkgs.python3Packages.plumbum ];
                flakeIgnore = [ "E265" ];
              }
              (builtins.readFile "${self}/scripts/uglinker.py");
          in
          ''
            ${uglinker} \
              $oldGenPath/home-files/.local/linkstate \
              $newGenPath/home-files/.local/linkstate

            echo newGenPath $newGenPath
            echo oldGenPath $oldGenPath
          '';
      };
      ".local/repo" = {
        source = self;
        recursive = true;
      };
    };
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
