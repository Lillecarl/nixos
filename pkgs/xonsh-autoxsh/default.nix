{ lib
, python3Packages
}:

python3Packages.buildPythonPackage rec {
  pname = "xonsh-autoxsh";
  version = "0.3";
  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "sha256-qwXbNbQ5mAwkZ4N+htv0Juw2a3NF6pv0XpolLIQfIe4=";
  };

  meta = {
    description = "Auto launcher of `.autoxsh` scripts for Xonsh shell's `cd` function";
    homepage = "https://github.com/Granitosaurus/xonsh-autoxsh";
    license = lib.licenses.gpl2;
  };
}
