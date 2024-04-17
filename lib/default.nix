lib:
let
  bs = builtins;
in
{
  rimport = sources: regexes:
    let
      regexList =
        let
          list = lib.toList regexes;
        in
        lib.throwIf (lib.any (regex: bs.typeOf regex != "string") list) "regexes must be a string or a list of string" list;
    in
    lib.pipe (lib.toList sources) [
      # Make sure consumers don't stuff the wrong types
      (sourcePaths: lib.throwIf (lib.any (path: bs.typeOf path != "path") sourcePaths) "sources must be path or list of path" sourcePaths)
      # Bring all .nix files into the store
      (sourcePaths: bs.map (path: lib.sources.sourceFilesBySuffices path [ ".nix" ]) sourcePaths)
      # Get all "file store paths" from the folder store paths
      (storePaths: bs.map (path: lib.filesystem.listFilesRecursive path) storePaths)
      # Flatten "list of list of file store path" to "list of file store path"
      (storeFilesLists: lib.flatten storeFilesLists)
      # Filter out possible duplicates
      (files: lib.unique files)
      # Convert paths to strings for regex matching
      (files: bs.map (path: "${path}") files)
      # Filter out files that don't match the regex
      (files: lib.filter (path: lib.any (re: bs.match re path != null) regexList) files)
    ];
}
