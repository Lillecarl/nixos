{ lib
, fetchPypi
, buildPythonPackage
, fetchFromGitHub
, setuptools
, pytest
}:
buildPythonPackage rec {
  pname = "pytest-tempdir";
  version = "2019.10.12";

  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-59kYE6mqmR24faze+M/T8WV2Mtcx1W0GI4xf+2OrNtg=";
  };

  propagatedBuildInputs = [
    setuptools
    pytest
  ];

  meta = {
    description = "Predictable and repeatable tempdir support.";
    homepage = "https://github.com/saltstack/pytest-tempdir";
    license = lib.licenses.asl20;
  };
}
