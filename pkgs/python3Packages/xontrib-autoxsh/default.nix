{ lib
, python3Packages
, fetchFromGitHub
}:
let
  versiondata = (builtins.fromJSON (builtins.readFile ./version.json));
in
python3Packages.buildPythonPackage rec {
  pname = "xontrib-autoxsh";
  version = versiondata.version;
  src = fetchFromGitHub versiondata;

  meta = {
    description = "Auto launcher of `.autoxsh` scripts for Xonsh shell's `cd` function";
    homepage = "https://github.com/Lillecarl/xontrib-autoxsh";
    license = lib.licenses.gpl2;
  };
}
