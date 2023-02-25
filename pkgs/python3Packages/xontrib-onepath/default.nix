{ lib
, python3Packages
, fetchFromGitHub
}:
let
  versiondata = (builtins.fromJSON (builtins.readFile ./version.json));
in
python3Packages.buildPythonPackage rec {
  pname = "xontrib-onepath";
  version = versiondata.version;
  src = fetchFromGitHub versiondata;
  propagatedBuildInputs = with python3Packages; [
    python-magic
  ];

  meta = {
    description = "Associate files and directories with app or alias and run it without preceding commands in xonsh shell.";
    homepage = "https://github.com/${versiondata.owner}/${versiondata.repo}";
    license = lib.licenses.mit;
  };
}
