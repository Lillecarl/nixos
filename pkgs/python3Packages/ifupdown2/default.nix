{ lib
, fetchFromGitHub
, buildPythonPackage
, setuptools
, six
, systemd
}:
let
  versiondata = builtins.fromJSON (builtins.readFile ./version.json);
in
buildPythonPackage {
  pname = "ifupdown2";
  version = "3.3.0";
  src = fetchFromGitHub versiondata;

  propagatedBuildInputs = [
    setuptools
    six
    systemd
  ];

  meta = {
    description = "Linux Interface Network Manager 2";
    homepage = "https://github.com/Lillecarl/ifupdown2";
    license = lib.licenses.gpl2;
  };
}
