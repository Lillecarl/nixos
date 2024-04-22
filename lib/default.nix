{ outPath
, lib
, ...
}:
let
  bs = builtins;
  all_files =
    let
      basePath = bs.toString outPath;
    in
    # listFilesRecursive returns absolute store paths
    lib.pipe (lib.filesystem.listFilesRecursive basePath) [
      (paths: bs.map
        (path: {
          # Remove store prefix
          noPrefix = lib.removePrefix basePath path;
          # Path as string
          sPath = bs.toString path;
        })
        paths)
      # Only Nix files
      (paths: lib.filter (path: lib.hasSuffix ".nix" path.sPath) paths)
    ];
in
rec {
  trace = trace: bs.trace (bs.toJSON trace) trace;

  _rimport = { path, regadd ? ".*", regdel ? "" }:
    let
      pathInfo =
        rec {
          # Path where we look for files
          sPath = bs.toString path;
          # Root of the flake, used to replace store paths with absolute "disk paths"
          sFlakeRoot = (lib.filesystem.locateDominatingFile "flake.nix" sPath).path;
          inherit outPath;
        };

      discardFilter = dpaths: dfilter: dname: bs.map (dpath: dpath // { discarded = dpath.discarded ++ (if dfilter dpath then [ dname ] else [ ]); }) dpaths;

      regadds = lib.toList regadd;
      regdels = lib.toList regdel;

      filteredFiles = lib.pipe all_files [
        (paths: bs.map
          (path: path // {
            # Replace store path with absolute "disk path"
            newPrefix = pathInfo.sFlakeRoot + path.noPrefix;
            discarded = [ ];
          })
          paths)
        # Match absolute "disk path" location with files absolute "disk path" location
        (paths: discardFilter paths (path: !lib.hasPrefix pathInfo.sPath path.newPrefix) "prefix")
        # Match positive regex
        #(paths: bs.map (path: path // { discarded = (path.discarded || !lib.any (re: bs.match re path.newPrefix != null) regadds); }) paths)
        (paths: discardFilter paths (path: lib.all (re: bs.match re path.newPrefix == null) regadds) "regadd")
        # Match negative regex
        #(paths: bs.map (path: path // { discarded = (path.discarded || !lib.all (re: bs.match re path.newPrefix == null) regdels); }) paths)
        (paths: discardFilter paths (path: lib.any (re: bs.match re path.newPrefix != null) regdels) "regdel")
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
      # Run _rimport for each path
      (res: bs.map (subres: _rimport (args // { path = subres; })) res)
      # Get the file lists
      (res: bs.map (subres: subres.files) res)
      # Flatten the lists
      (res: lib.flatten res)
      # Remove discarded files
      (res: bs.filter (subres: bs.length subres.discarded == 0) res)
      # Extract the paths
      (res: bs.map (subres: subres.sPath) res)
    ];

  rimport = args: _rimportMulti args;
}
