{ lib
, python3Packages
}:

python3Packages.buildPythonPackage rec {
  pname = "repassh";
  version = "1.2.0";
  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "sha256-uerGQg/c+7LkDyenSeLjPaMMVCNZyMPw1atxhiQrIYI=";
  };

  meta = {
    description = "SSH agent integration for xonsh";
    homepage = "https://github.com/dyuri/${pname}";
    license = lib.licenses.mit;
  };
}
