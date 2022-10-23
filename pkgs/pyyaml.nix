{ lib
, python3
}:

python3.pkgs.buildPythonPackage rec {
  pname = "PyYAML";
  version = "6.0";
  src = python3.pkgs.fetchPypi {
    inherit pname version;
    sha256 = "sha256-aPtRnBQwb+yXIKKltFvJ8MjRuccq30XDe67fzZScNaI=";
  };

  meta = {
    description = "fzf widgets for xonsh.";
    homepage = "https://github.com/laloch/${pname}";
    license = lib.licenses.mit;
  };
}
