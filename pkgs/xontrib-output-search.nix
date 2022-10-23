{ lib
, pkgs
, python3
}:

python3.pkgs.buildPythonPackage rec {
  pname = "xontrib-output-search";
  version = "0.6.2";
  src = python3.pkgs.fetchPypi {
    inherit pname version;
    sha256 = "sha256-Zh4DXs5qajZ3bR2YVJ+uLE2u1TVJcmdzH3x9nX6jJDI=";
  };

  propagatedBuildInputs = with python3.pkgs; [
    pkgs.tokenize-output
  ];

  meta = {
    description = "Get identifiers, paths, URLs and words from the previous command output and use them for the next command in xonsh shell.";
    homepage = "https://github.com/anki-code/${pname}";
    license = lib.licenses.mit;
  };
}
