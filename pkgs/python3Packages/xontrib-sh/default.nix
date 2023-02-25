{ lib
, python3Packages
, fetchFromGitHub
}:
let
  versiondata = (builtins.fromJSON (builtins.readFile ./version.json));
in
python3Packages.buildPythonPackage rec {
  pname = "xontrib-sh";
  version = versiondata.version;
  src = fetchFromGitHub versiondata;

  meta = {
    description = "Bang bash oneliners within xonsh";
    homepage = "https://github.com/anki-code/${pname}";
    license = lib.licenses.mit;
  };
}
