{ lib
, python3
}:

python3.pkgs.buildPythonPackage rec {
  pname = "xontrib-fzf-widgets";
  version = "0.0.4";
  src = python3.pkgs.fetchPypi {
    inherit pname version;
    sha256 = "sha256-EpeOr9c3HwFdF8tMpUkFNu7crmxqbL1VjUg5wTzNzUk=";
  };

  meta = {
    description = "fzf widgets for xonsh.";
    homepage = "https://github.com/laloch/${pname}";
    license = lib.licenses.mit;
  };
}
