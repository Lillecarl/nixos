{ lib
, xonsh-unwrapped
, python3Packages
, fetchFromGitHub
,
}:
let
  versiondata = builtins.fromJSON (builtins.readFile ./version.json);
in
python3Packages.buildPythonPackage rec {
  pname = "xontrib-jump-to-dir";
  version = versiondata.version;
  src = fetchFromGitHub versiondata;

  propagatedBuildInputs = [ xonsh-unwrapped ];

  meta = {
    description = "Jump to used before directory by part of the path. Lightweight zero-dependency implementation of autojump or zoxide projects functionality.";
    homepage = "https://github.com/${versiondata.owner}/${versiondata.repo}";
    license = lib.licenses.mit;
  };
}
