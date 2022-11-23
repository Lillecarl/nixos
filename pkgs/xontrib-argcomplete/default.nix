{ lib
, python3Packages
}:

python3Packages.buildPythonPackage rec {
  pname = "xontrib-argcomplete";
  version = "0.3.2";
  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "sha256-jn1NHh/PTTgSX0seOvOZTpRv4PxAQ4PbDiXOSb4/jrU=";
  };

  propagatedBuildInputs = with python3Packages; [
    argcomplete
  ];

  meta = {
    description = "Argcomplete support for python and xonsh scripts in xonsh shell.";
    homepage = "https://github.com/anki-code/${pname}";
    license = lib.licenses.mit;
  };
}
