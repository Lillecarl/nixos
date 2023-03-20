{ lib
, python3Packages
, fetchFromGitHub
, pytest
, setuptools
, munch
}:
let
  versiondata = (builtins.fromJSON (builtins.readFile ./version.json));
in
python3Packages.buildPythonPackage rec {
  pname = "from_ssv";
  version = versiondata.version;
  src = fetchFromGithub versiondata;

  propagatedBuildInputs = [
    pytest
    setuptools
    munch
  ];

  meta = {
    description = "Convert space separated lists into list of dicts";
    homepage = "https://github.com/lillecarl";
    license = lib.licenses.mit;
  };
}
