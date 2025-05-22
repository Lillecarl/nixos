{
  fetchFromGitHub,
  buildPythonPackage,
  setuptools-scm,
  cryptography,
  pillow,
  pyopenssl,
  requests,
  service-identity,
  twisted,
}:
let
  pname = "konnect";
  version = "0.3.0";
in
buildPythonPackage {
  inherit pname version;
  src = fetchFromGitHub {
    owner = "metallkopf";
    repo = "konnect";
    rev = version;
    sha256 = "sha256-UNI0fncPCzAmhfwIiGDklUEM1FSgoOBAJ0aqOhREtu8=";
  };
  pyproject = true;
  nativeBuildInputs = [ setuptools-scm ];
  propagatedBuildInputs = [
    cryptography
    pillow
    pyopenssl
    requests
    service-identity
    twisted
  ];
}
