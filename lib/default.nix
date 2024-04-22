{ outPath
, lib
}:
let
  bs = builtins;
  all_files =
    let
      basePath = builtins.toString outPath;
    in
    lib.pipe (lib.filesystem.listFilesRecursive basePath) [
      (paths: builtins.map
        (path: {
          noPrefix = lib.removePrefix basePath path;
          pPath = path;
          sPath = bs.toString path;
        })
        paths)
    ];
in
rec {
  trace = trace: bs.trace (builtins.toJSON trace) trace;

  _rimport = { path, regadd ? ".*", regdel ? "" }:
    let
      pathInfo =
        rec {
          pPath = path;
          sPath = bs.toString path;
          sFlakeRoot = (lib.filesystem.locateDominatingFile "flake.nix" sPath).path;
        };

      regadds = lib.toList regadd;
      regdels = lib.toList regdel;

      filteredFiles = lib.pipe all_files [
        (paths: bs.map
          (path: path // {
            newPrefix = pathInfo.sFlakeRoot + path.noPrefix;
          })
          paths)
        # Only Nix files
        (paths: lib.filter (path: lib.hasSuffix ".nix" path.sPath) paths)
        # Match path location
        (paths: lib.filter (path: lib.hasPrefix pathInfo.sPath path.newPrefix) paths)
        # Match positive regex
        (paths: lib.filter (path: lib.any (re: bs.match re path.newPrefix != null) regadds) paths)
        # Match negative regex
        (paths: lib.filter (path: lib.any (re: bs.match re path.newPrefix == null) regdels) paths)
      ];
    in
    {
      files =
        if
          builtins.length filteredFiles == 0
        then
          lib.warn ''
            No files found to import from
            "${pathInfo.sPath}"
            with regex(add)
            "${regadd}"
            and regex(sub)
            "${regdel}"
          ''
            filteredFiles
        else
          filteredFiles;
      inherit pathInfo;
    };

  rimport = args: lib.pipe (_rimport args).files [
    (paths: bs.map (path: path.pPath) paths)
  ];
}
