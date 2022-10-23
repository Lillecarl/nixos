{ lib
, pkgs
, python
, buildPythonPackage
, fetchPypi
}:

buildPythonPackage rec {
  pname = "tokenize-output";
  version = "0.4.7";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-b/ffh5l6YO9A20vtekBGXLMZdfXfrzU9nzXyxa7xZR0=";
  };

  propagatedBuildInputs = with pkgs.python3Packages; [
    demjson3
  ];

  meta = {
    description = "Get identifiers, paths, URLs and words from a string.";
    homepage = "https://github.com/anki-code/${pname}";
    license = lib.licenses.mit;
  };
}
