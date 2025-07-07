{
  lib,
  pkgs,
  repositoryLocation,
  self,
  config,
  ...
}:
let
  dotfilesPath = "${repositoryLocation}/users/lillecarl/dotfiles";
  fromTo = builtins.map (
    path:
    let
      name = lib.removePrefix dotfilesPath path;
    in
    {
      src = path;
      dst = "${config.home.homeDirectory}${name}";
    }
  ) (lib.filesystem.listFilesRecursive dotfilesPath);
in
{
  home = {
    file = {
      ".local/linkstate" = {
        text = builtins.toJSON fromTo;
        onChange =
          let
            uglinker = pkgs.writers.writePython3 "uglinker" {
              libraries = [ pkgs.python3Packages.plumbum ];
              flakeIgnore = [ "E265" ];
            } (builtins.readFile "${self}/scripts/uglinker.py");
          in
          ''
            set +u #oldGenPath is unset the first time we're running home-manager
            ${uglinker} \
              "$oldGenPath/home-files/.local/linkstate" \
              "$newGenPath/home-files/.local/linkstate"

            echo newGenPath $newGenPath
            echo oldGenPath $oldGenPath
            set -u
          '';
      };
      ".local/repo" = {
        source = self;
        # recursive = true;
      };
    };
  };
}
