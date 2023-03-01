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
    rev = version;
    sha256 = "sha256-mk/g83hF+2xwyU+AfTlwAkHHuKu3d9xlS5DhDYJuZqg=";
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
