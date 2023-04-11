{ lib
, fetchFromGitHub
, buildPythonPackage
, setuptools
, six
}:
let
  versiondata = (builtins.fromJSON (builtins.readFile ./version.json));
in
buildPythonPackage rec {
  pname = "ifupdown2";
  version = "3.0.0-1";
  src = fetchFromGitHub versiondata;

  propagatedBuildInputs = [
    setuptools
    six
  ];

  meta = {
    description = "Linux Interface Network Manager 2";
    homepage = "https://github.com/Lillecarl/ifupdown2";
    license = lib.licenses.gpl2;
  };
}
