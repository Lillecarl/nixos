{ lib
, fetchPypi
, buildPythonPackage
, fetchFromGitHub
, setuptools
}:
buildPythonPackage rec {
  pname = "pytest-salt-factories";
  version = "0.912.2";

  format = "pyproject";

  src = fetchFromGitHub {
    owner = "saltstack";
    repo = "pytest-salt-factories";
    rev = "v${version}";
    sha256 = "h56Gx/MMCW4L6nGwLAhBkiR7bX+qfFk80LEsJMiDtjQ=";
  };

  propagatedBuildInputs = [
    setuptools
  ];

  meta = {
    description = "PyTest Salt Factories Plugin";
    homepage = "https://github.com/saltstack/pytest-salt-factories";
    license = lib.licenses.asl20;
  };
}
