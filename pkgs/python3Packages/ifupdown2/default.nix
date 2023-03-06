{ lib
, python3Packages
, fetchFromGitHub
}:
let
  versiondata = (builtins.fromJSON (builtins.readFile ./version.json));
in
python3Packages.buildPythonPackage rec {
  pname = "ifupdown2";
  version = "3.0.0-1";
  src = fetchFromGitHub versiondata;

  propagatedBuildInputs = with python3Packages; [
    six
  ];

  meta = {
    description = "Linux Interface Network Manager 2";
    homepage = "https://github.com/CumulusNetworks/ifupdown2";
    license = lib.licenses.gpl2;
  };
}
