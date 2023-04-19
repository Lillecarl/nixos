{ lib
, fetchPypi
, buildPythonPackage
, setuptools
,
}:
buildPythonPackage rec {
  pname = "pytest-skip-markers";
  version = "1.4.0";

  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-EJXF0RA9d3ecvoBeqKe+6zvm5GUpd4+xynLkJQz6jsI=";
  };

  propagatedBuildInputs = [
    setuptools
  ];

  meta = {
    description = "A Pytest plugin which implements a few useful skip markers";
    homepage = "https://github.com/saltstack/pytest-skip-markers";
    license = lib.licenses.asl20;
  };
}
