{ lib
, fetchPypi
, buildPythonPackage
, hatchling
}:
buildPythonPackage rec {
  pname = "looseversion";
  version = "1.1.2";

  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-lNgL29C21XwRuIYUe6FgH30VMVcWIbgZM7NFN8vkaa0=";
  };

  nativeBuildInputs = [
    hatchling
  ];

  meta = {
    description = "Version numbering for anarchists and software realists";
    homepage = "https://github.com/effigies/looseversion";
    license = lib.licenses.psfl;
  };
}
