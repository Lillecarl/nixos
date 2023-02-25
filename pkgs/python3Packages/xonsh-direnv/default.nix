{ lib
, python3Packages
, fetchFromGitHub
}:
let
  versiondata = (builtins.fromJSON (builtins.readFile ./version.json));
in
python3Packages.buildPythonPackage rec {
  pname = "xonsh-direnv";
  version = "0.3.0";
  src = fetchFromGitHub versiondata;

  meta = {
    description = "xonsh extension for using direnv";
    homepage = "https://github.com/${versiondata.owner}/${versiondata.repo}";
    license = lib.licenses.mit;
  };
}
