{
  lib,
  pkgs,
  flakeloc,
  self,
  config,
  ...
}:
let
  dotfilesPath = "${flakeloc}/users/lillecarl/dotfiles";
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
            # Work around -u
            export OGP=""
            if [ -n "''${oldGenPath+.}" ]
            then
              export OGP="$oldGenPath"
            fi
            
            ${uglinker} \
              "$OGP/home-files/.local/linkstate" \
              "$newGenPath/home-files/.local/linkstate"

            echo newGenPath $newGenPath
            echo oldGenPath $oldGenPath
          '';
      };
      ".local/repo" = {
        source = self;
        # recursive = true;
      };
    };
  };
}
