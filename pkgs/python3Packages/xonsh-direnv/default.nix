{ lib
, python3Packages
}:

python3Packages.buildPythonPackage rec {
  pname = "xonsh-direnv";
  version = "1.6.1";
  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "sha256-Nt8Da1EtMVWZ9mbBDjys7HDutLYifwoQ1HVmI5CN2Ww=";
  };
  meta = {
    description = "xonsh extension for using direnv";
    homepage = "https://github.com/Granitosaurus/${pname}";
    license = lib.licenses.mit;
  };
}
