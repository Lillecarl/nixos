{ fetchFromGitLab
, python3Packages
, setuptools-scm
}:
let
  pname = "qemu-qmp";
  version = "0.0.3";
in
python3Packages.buildPythonPackage {
  inherit pname version;
  src = fetchFromGitLab {
    owner = "qemu-project";
    repo = "python-qemu-qmp";
    rev = "v${version}";
    sha256 = "sha256-NOtBea81hv+swJyx8Mv2MIqoK4/K5vyMiN12hhDEpJY=";
  };
  pyproject = true;
  nativeBuildInputs = [ setuptools-scm ];
}
