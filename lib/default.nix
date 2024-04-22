{ outPath
, lib
}:
let
  bs = builtins;
  all_files = let
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
  # sources: a path or a list of paths
  # regexes: a regex or a list of regexes
  rimport1 = sources: regexes:
    let
      #storeMatch = str: builtins.match "^(/nix/store/.*-source/).*$" str;
      regexList = lib.toList regexes;
      sourceList = lib.toList sources;

      modulePaths = lib.flatten (bs.map (path: (lib.filesystem.listFilesRecursive path)) sourceList);
      nixFiltered = lib.filter (path: bs.match ".*\.nix" (builtins.toString path) != null) modulePaths;
      userFiltered = lib.filter (path: lib.any (re: bs.match re (builtins.toString path) != null) regexList) nixFiltered;
    in
    userFiltered;

  raimport = { source, regadd ? ".*", regdel ? "" }:
    let
      modulePaths = lib.filesystem.listFilesRecursive source;
      nixFiltered = lib.filter (path: bs.match ".*\.nix" (builtins.toString path) != null) modulePaths;
      addFiltered = lib.filter (path: bs.match regadd (builtins.toString path) != null) nixFiltered;
      delFiltered = lib.filter (path: bs.match regdel (builtins.toString path) == null) addFiltered;
    in
    delFiltered;

  infinimport = { source, callpath ? ./., regadd ? ".*", regdel ? "" }:
    let
      sources = lib.toList source;
      regadds = lib.toList regadd;
      regdels = lib.toList regdel;

      getDir = dir: lib.mapAttrs
        (file: type:
          if type == "directory" then getDir "${dir}/${file}" else type
        )
        (builtins.readDir dir);

      # Collects all files of a directory as a list of strings of paths
      getFiles = dir:
        lib.collect
          lib.isString
          (lib.mapAttrsRecursive
            (path: type:
              lib.concatStringsSep
                "/"
                path
            )
            (getDir dir)
          );

      mf = lib.pipe sources [
        (sources:
          bs.map
            (source:
              bs.map
                (file:
                  rec {
                    ppath = file;
                    spath = "${file}";
                    proot = source;
                    sroot = "${source}";
                    sroot2 = builtins.toString proot;
                    t1 = ./. + sroot2 + "/${ppath}";
                    t2 = ./. + "/${ppath}";
                    t3 = /. + "/${ppath}";
                    t4 = /. + sroot2 + "/${ppath}";
                    t5 = "${t4}";
                    t6 = ./. + "/${ppath}";
                    t8 = (sroot2 + "/${ppath}");
                    t9 = /. + "${t9}";
                    t10 = /. + (sroot2 + "/${ppath}");
                  })
                (getFiles source)
            )
            sources)
        (fileAttrs: (lib.flatten fileAttrs))
        (files: lib.filter (file: lib.hasSuffix ".nix" file.ppath) files)
        (files: lib.filter (file: lib.any (re: bs.match re file.ppath != null) regadds) files)
        (files: lib.filter (file: lib.any (re: bs.match re file.ppath == null) regdels) files)
        #(files: bs.map (file: /. + (file.root + "/${file.path}")) files)
        #(files: bs.map (file: file.t8) files)
      ];
    in
    mf;


  umport2 = { path, regadd ? ".*", regdel ? "" }:
    let
      pathInfo =
        rec {
          pPath = path;
          sPath = bs.toString path;
          pFlakeRoot = (lib.filesystem.locateDominatingFile "flake.nix" pPath).path;
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

  umport3 = args: (bs.map (file: file.newPrefix) (umport2 args).files);

  flake_import = umport3;
  nub_import = args: (bs.map (file: file.newPrefix) (umport2 args).files);
  rimport = raimport;

  lilimport = { source, regadd ? ".*", regdel ? "" }:
    let
      sources = lib.toList source;
      files = lib.flatten (bs.map (source: infinimport source) sources);
      addFiltered = lib.filter (path: bs.match regadd (builtins.toString path) != null) files;
      delFiltered = lib.filter (path: bs.match regdel (builtins.toString path) != null) addFiltered;
    in
    delFiltered;
}
