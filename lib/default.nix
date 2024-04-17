lib:
let
  bs = builtins;
in
rec {
  trace = trace: bs.trace trace trace;
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

  rimport = rimport1;
}
