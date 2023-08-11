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
  pname = "xontrib-back2dir";
  version = versiondata.version;
  src = fetchFromGitHub versiondata;
  propagatedBuildInputs = with python3Packages; [
    argcomplete
    xonsh
  ];

  meta = {
    description = "Return to the most recently used directory when starting the xonsh shell. ";
    homepage = "https://github.com/${versiondata.owner}/${versiondata.repo}";
    license = lib.licenses.mit;
  };
}
