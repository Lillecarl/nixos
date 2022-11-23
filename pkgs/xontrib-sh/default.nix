{ lib
, python3Packages
}:

python3Packages.buildPythonPackage rec {
  pname = "xontrib-sh";
  version = "0.3.0";
  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "sha256-eV++ZuopnAzNXRuafXXZM7tmcay1NLBIB/U+SVrQV+U=";
  };

  meta = {
    description = "Bang bash oneliners within xonsh";
    homepage = "https://github.com/anki-code/${pname}";
    license = lib.licenses.mit;
  };
}
