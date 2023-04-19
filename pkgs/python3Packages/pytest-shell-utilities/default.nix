{ lib
, fetchPypi
, buildPythonPackage
, setuptools
,
}:
buildPythonPackage rec {
  pname = "pytest-shell-utilities";
  version = "1.7.0";

  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-mKeNepxTheBm8Eu/613xtD122dPUV0nEJnOF9YuZ91E=";
  };

  propagatedBuildInputs = [
    setuptools
  ];

  meta = {
    description = "Pytest plugin to simplify running shell commands against the system";
    homepage = "https://github.com/saltstack/pytest-shell-utilities";
    license = lib.licenses.asl20;
  };
}
