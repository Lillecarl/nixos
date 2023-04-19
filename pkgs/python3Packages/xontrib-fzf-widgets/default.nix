{ lib
, python3Packages
, fetchFromGitHub
,
}:
let
  versiondata = builtins.fromJSON (builtins.readFile ./version.json);
in
python3Packages.buildPythonPackage rec {
  pname = "xontrib-fzf-widgets";
  version = versiondata.version;
  src = fetchFromGitHub versiondata;
  meta = {
    description = "fzf widgets for xonsh.";
    homepage = "https://github.com/${versiondata.owner}/${versiondata.repo}";
    license = lib.licenses.mit;
  };
}
