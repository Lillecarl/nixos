{ lib
, python3Packages
, fetchFromGitHub
}:
let
  versiondata = (builtins.fromJSON (builtins.readFile ./version.json));
in
python3Packages.buildPythonPackage rec {
  pname = "xonsh-autoxsh";
  version = "0.3";
  src = fetchFromGitHub versiondata;
  meta = {
    description = "Auto launcher of `.autoxsh` scripts for Xonsh shell's `cd` function";
    homepage = "https://github.com/Granitosaurus/xonsh-autoxsh";
    license = lib.licenses.gpl2;
  };
}
