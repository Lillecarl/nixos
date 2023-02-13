{ lib
, python3Packages
}:

python3Packages.buildPythonPackage rec {
  pname = "salt-pepper";
  version = "0.7.6";

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "sha256-t1pkHU/ZZmOuRPx85KrbfkyHuP8w96w1R5ooK5mJR0k=";
  };

  propagatedBuildInputs = with python3Packages; [
    setuptools-scm
  ];

  doCheck = false;

  meta = {
    description = "A CLI front-end to a running salt-api system";
    homepage = "https://github.com/saltstack/pepper";
    license = lib.licenses.asl20;
  };
}
