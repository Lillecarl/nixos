{ lib
, python3Packages
, fetchFromGitHub
,
}:
let
  versiondata = builtins.fromJSON (builtins.readFile ./version.json);
in
python3Packages.buildPythonPackage rec {
  pname = "xontrib-output-search";
  version = versiondata.version;
  src = fetchFromGitHub versiondata;
  propagatedBuildInputs = with python3Packages; [
    tokenize-output
  ];

  meta = {
    description = "Get identifiers, paths, URLs and words from the previous command output and use them for the next command in xonsh shell.";
    homepage = "https://github.com/anki-code/${pname}";
    license = lib.licenses.mit;
  };
}
