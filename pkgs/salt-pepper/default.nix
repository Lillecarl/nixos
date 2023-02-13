{ lib
, python3Packages
}:

python3Packages.buildPythonPackage rec {
  pname = "salt-pepper";
  version = "0.7.6";

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "sha256-qwXbNbQ5mAwkZ4N+htv0Juw2a3NF6pv0XpolLIQfIe4=";
  };

  meta = {
    description = "A CLI front-end to a running salt-api system";
    homepage = "https://github.com/saltstack/pepper";
    license = lib.licenses.apache2;
  };
}
