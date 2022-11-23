{ lib
, python3Packages
, repassh
}:

python3Packages.buildPythonPackage rec {
  pname = "xontrib-ssh-agent";
  version = "1.0.13";
  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "sha256-XfrZ1ALl71anA/WeOAIBlifAE9ruoZPqD/blkJlf5fw=";
  };

  propagatedBuildInputs = with python3Packages; [
    repassh
  ];
  meta = {
    description = "SSH agent integration for xonsh";
    homepage = "https://github.com/dyuri/${pname}";
    license = lib.licenses.mit;
  };
}
