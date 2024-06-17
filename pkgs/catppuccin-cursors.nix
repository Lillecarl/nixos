{ lib
, stdenvNoCC
, fetchFromGitHub
, inkscape
, just
, xcursorgen
}:
let
  src1 = fetchFromGitHub {
    owner = "catppuccin";
    repo = "cursors";
    rev = "v${version}";
    hash = "sha256-aQfbziN5z62LlgVq4CNMXVMmTrzChFgWUMAmO/2/z3Y=";
  };
  src = /home/lillecarl/Code/carl/cursors;

  capitalizeFirst = str:
    let
      list = lib.stringToCharacters str;
      first = lib.head list;
      upper = lib.toUpper first;
      noPrefix = lib.removePrefix first str;
      out = lib.concatStrings [ upper noPrefix ];
    in
    out;

  cursors-list = stdenvNoCC.mkDerivation {
    pname = "catppuccin-cursors-info";
    inherit version src;
    buildPhase = "";

    nativeBuildInputs = [ just ];

    installPhase = ''
      mkdir $out

      just flavors > $out/flavors
      just accents > $out/accents
    '';
  };

  cursorPackage = { flavor, accent }:
    let
      variant = "${flavor}-${accent}";
      capitalizedFlavor = capitalizeFirst flavor;
      capitalizedAccent = capitalizeFirst accent;
    in
    stdenvNoCC.mkDerivation
      {
        pname = "catppuccin-cursors-${variant}";
        inherit version;
        inherit (cursors-list) src;

        nativeBuildInputs = [ just inkscape xcursorgen ];

        #outputs = variants ++ [ "out" ]; # dummy "out" output to prevent breakage

        #outputsToInstall = [ ];

        buildPhase = ''
          runHook preBuild

          patchShebangs .

          just build ${flavor} ${accent}

          runHook postBuild
        '';

        installPhase = ''
          runHook preInstall

          local iconsDir="$out"/share/icons
          local distDir="catppuccin-${variant}-cursors"
          mkdir -p "$iconsDir"
          mv "dist/$distDir" "$iconsDir"
          ln -s "$iconsDir/$distDir" "$iconsDir/Catppuccin-${capitalizedFlavor}-${capitalizedAccent}"

          runHook postInstall
        '';

        passthru = {
          themeName = "Catppuccin-${capitalizedFlavor}-${capitalizedAccent}";
          themeDir = "catppuccin-${variant}-cursors";
        };

        meta = {
          description = "Catppuccin cursor theme based on Volantes";
          homepage = "https://github.com/catppuccin/cursors";
          license = lib.licenses.gpl2;
          platforms = lib.platforms.linux;
          maintainers = with lib.maintainers; [ dixslyf ];
        };
      };

  dimensions = {
    flavors = lib.pipe (builtins.readFile "${cursors-list}/flavors") [ (x: lib.strings.removeSuffix "\n" x) (lib.splitString " ") ];
    accents = lib.pipe (builtins.readFile "${cursors-list}/accents") [ (x: lib.strings.removeSuffix "\n" x) (lib.splitString " ") ];
  };

  version = "0.2.1";
in
lib.pipe dimensions [
  (x: lib.mapCartesianProduct ({ flavors, accents }: { inherit flavors accents; }) x)
  (x: map
    (variant: {
      name = "${variant.flavors}${capitalizeFirst variant.accents}";
      value = cursorPackage { flavor = variant.flavors; accent = variant.accents; };
    })
    x
  )
  (x: lib.listToAttrs x)
]
