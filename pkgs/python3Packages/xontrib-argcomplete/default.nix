{ lib
, python3Packages
, xonsh
, fetchFromGitHub
,
}:
let
  versiondata = builtins.fromJSON (builtins.readFile ./version.json);
in
python3Packages.buildPythonPackage rec {
  pname = "xontrib-argcomplete";
  version = versiondata.version;
  src = fetchFromGitHub versiondata;
  propagatedBuildInputs = with python3Packages; [
    argcomplete
    xonsh
  ];

  meta = {
    description = "Argcomplete support for python and xonsh scripts in xonsh shell.";
    homepage = "https://github.com/${versiondata.owner}/${versiondata.repo}";
    license = lib.licenses.mit;
  };
}
