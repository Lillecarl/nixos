let
  host = builtins.getEnv "HOST";
  _flakePath = /home/lillecarl/Code/nixos;
  flake = builtins.getFlake (toString _flakePath);
  inherit (flake.nixosConfigurations) nub;
  inherit (flake.nixosConfigurations) shitbox;
  bs = builtins;
  pkgs =
    if
      host == "nub" then nub.pkgs
    else if
      host == "shitbox" then shitbox.pkgs
    else
      throw "Unknown host ${host}";
  inherit (pkgs) lib;
  inherit (flake) nixosConfigurations;
in
rec {
  inherit
    flake
    pkgs
    lib
    nixosConfigurations
    nub
    shitbox
    host;

  self = flake;

  slib = import ./lib { outPath = self.outPath; inherit lib; };
  nub_home = flake.homeConfigurations."lillecarl@nub";
  shitbox_home = flake.homeConfigurations."lillecarl@shitbox";
  umport = (import "${flake.inputs.nypkgs}/lib/umport.nix" { lib = flake.inputs.nixpkgs.lib; }).umport;
  all_nix = bs.map
    (path: {
      inherit path;
      implicitString = "${path}";
      toString = bs.toString path;
    })
    (umport { path = ./.; });

  umport2 = { path, regadd ? ".*", regdel ? "" }:
    let
      pathInfo =
        {
          inherit path;
          implicitString = "${path}";
          toString = bs.toString path;
        };
      regadds = lib.toList regadd;
      regdels = lib.toList regdel;

      filteredFiles = lib.pipe all_nix [
        # Filter for our directory
        (paths: lib.filter (path: lib.hasPrefix pathInfo.toString path.toString) paths)
        (paths: lib.filter (path: lib.any (re: bs.match re path.toString != null) regadds) paths)
        (paths: lib.filter (path: lib.any (re: bs.match re path.toString == null) regdels) paths)
      ];
    in
    filteredFiles;

  #source = lib.cleanSource ./.;
  #files = lib.filesystem.listFilesRecursive ./.;
  #filter = path: builtins.match ".*" path;
  #filtered = builtins.filter filter files;

  fs = with lib.fileset;
    rec {
      files = toList ./.;
      filtered = lib.pipe files [
        (files: toSource { root = ./.; fileset = ./.; })
        (files: toList ./.)
      ];

      test1 = toSource {
        root = ./.;
        fileset = fromSource (lib.sources.cleanSource ./.);
      };
      test2 = gitTracked ./.;
      test3 = lib.pipe test2 [
        (files: toSource { root = ./.; fileset = files; })
        (files: lib.filesystem.listFilesRecursive files)
        (files: builtins.map (path: builtins.replaceStrings [ "/nix/store" ] [ "" ] path) files)
      ];

      test4 = lib.pipe (lib.filesystem.listFilesRecursive ./.) [
        (files: builtins.map (path: builtins.toString path) files)
        (files: builtins.filter (path: builtins.match ".*" path) files)
      ];

      test5 = lib.sourceByRegex ./. [
        "^.*nix$"
        ".*\.py$"
        ".*\.nix$"
      ];
      test6 = lib.filesystem.listFilesRecursive "${test5}";
      test7 = lib.sources.sourceFilesBySuffices ./. [ "nix" ];
      test8 = lib.filesystem.listFilesRecursive "${test7}";

      test9 = lib.pipe (lib.sources.sourceFilesBySuffices ./. [ ".nix" ]) [
        (source: lib.filesystem.listFilesRecursive source)
        (files: lib.filter (path: lib.filesystem.pathIsRegularFile path) files)
        (files: builtins.filter (path: (builtins.match ".*pkgs.*" path) != null) files)
      ];
    };
}
