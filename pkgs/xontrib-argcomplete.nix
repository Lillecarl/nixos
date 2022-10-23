{ lib
, python3
}:

python3.pkgs.buildPythonPackage rec {
  pname = "xontrib-argcomplete";
  version = "0.3.2";

  src = python3.pkgs.fetchPypi {
    inherit pname version;
    sha256 = "sha256-jn1NHh/PTTgSX0seOvOZTpRv4PxAQ4PbDiXOSb4/jrU=";
  };

  propagatedBuildInputs = with python3.pkgs; [
    argcomplete
  ];

  meta = {
    description = "Argcomplete support for python and xonsh scripts in xonsh shell.";
    homepage = "https://github.com/anki-code/${pname}";
    license = lib.licenses.mit;
  };
}
