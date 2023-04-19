{ lib
, python3Packages
, fetchFromGitHub
,
}:
let
  versiondata = builtins.fromJSON (builtins.readFile ./version.json);
in
python3Packages.buildPythonPackage rec {
  pname = "tokenize-output";
  version = versiondata.version;
  src = fetchFromGitHub versiondata;

  propagatedBuildInputs = with python3Packages; [
    demjson3
  ];

  meta = {
    description = "Get identifiers, paths, URLs and words from a string.";
    homepage = "https://github.com/anki-code/${pname}";
    license = lib.licenses.mit;
  };
}
