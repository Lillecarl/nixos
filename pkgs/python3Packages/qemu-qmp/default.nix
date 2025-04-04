{
  fetchFromGitLab,
  buildPythonPackage,
  setuptools-scm,
}:
let
  pname = "qemu-qmp";
  version = "0.0.3";
in
buildPythonPackage {
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
