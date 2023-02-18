{ lib
, python3Packages
}:

python3Packages.buildPythonPackage rec {
  pname = "xontrib-onepath";
  version = "0.3.2";
  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "sha256-xYLns/RW4L731fxJWXFBGuZL9d0szMdhXSRDhEehIiQ=";
  };

  propagatedBuildInputs = with python3Packages; [
    python-magic
  ];

  meta = {
    description = "Associate files and directories with app or alias and run it without preceding commands in xonsh shell.";
    homepage = "https://github.com/anki-code/${pname}";
    license = lib.licenses.mit;
  };
}
