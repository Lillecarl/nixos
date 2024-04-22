{ outPath
, lib
}:
let
  bs = builtins;
  all_files =
    let
      basePath = bs.toString outPath;
    in
    lib.pipe (lib.filesystem.listFilesRecursive basePath) [
      (paths: bs.map
        (path: {
          noPrefix = lib.removePrefix basePath path;
          sPath = bs.toString path;
        })
        paths)
    ];
in
rec {
  trace = trace: bs.trace (bs.toJSON trace) trace;

  _rimport = { path, regadd ? ".*", regdel ? "" }:
    let
      pathInfo =
        rec {
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
        (paths: lib.filter (path: lib.all (re: bs.match re path.newPrefix == null) regdels) paths)
      ];
    in
    {
      files =
        if
          bs.length filteredFiles == 0
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

  _rimportMulti = { path, regadd ? ".*", regdel ? "" }@args:
    lib.pipe (lib.toList path) [
      (res: bs.map (subres: _rimport (args // { path = subres; })) res)
      (res: bs.map (subres: subres.files) res)
      (res: lib.flatten res)
      (res: bs.map (subres: subres.sPath) res)
    ];

  rimport = args: _rimportMulti args;
}
