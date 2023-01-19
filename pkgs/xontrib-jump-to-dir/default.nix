{ lib
, python3Packages
, final
, prev
}:

python3Packages.buildPythonPackage rec {
  pname = "xontrib-jump-to-dir";
  version = "0.0.3";
  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "sha256-affmEnOeQWrbB2hYpkFxR6QSrdAU8Cty2ZwFJD22Y6I=";
  };

  propagatedBuildInputs = [ prev.xonsh ];

  meta = {
    description = "Jump to used before directory by part of the path. Lightweight zero-dependency implementation of autojump or zoxide projects functionality.";
    homepage = "https://github.com/anki-code/${pname}";
    license = lib.licenses.mit;
  };
}
