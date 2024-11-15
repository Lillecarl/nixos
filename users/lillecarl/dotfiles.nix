{ lib
, pkgs
, flakeloc
, self
, config
, nixosConfig
, ...
}:
let
  sub_path = "users/lillecarl/dotfiles";
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
  home = {
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
}
