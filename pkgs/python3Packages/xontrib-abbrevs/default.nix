{ lib
, python3Packages
, fetchFromGitHub
, xonsh-unwrapped
}:
let
  versiondata = builtins.fromJSON (builtins.readFile ./version.json);
in
python3Packages.buildPythonPackage {
  pname = "xontrib-sh";
  version = versiondata.version;
  src = fetchFromGitHub versiondata;

  propagatedBuildInputs = [ xonsh-unwrapped ];

  doCheck = false;

  meta = {
    description = "Expands input words as you type in your xonsh shell.";
    homepage = "https://github.com/xonsh/xontrib-abbrevs";
    license = lib.licenses.mit;
  };
}
