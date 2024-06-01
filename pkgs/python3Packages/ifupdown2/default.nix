{ lib
, fetchFromGitHub
, buildPythonPackage
, setuptools
, six
, systemd
, propagatedBuildInputs ? [ ]
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
  ] ++ propagatedBuildInputs;

  meta = {
    description = "Linux Interface Network Manager 2";
    homepage = "https://github.com/CumulusNetworks/ifupdown2";
    license = lib.licenses.gpl2;
  };
}
