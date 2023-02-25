{ lib
, python3Packages
, fetchFromGitHub
}:
let
  versiondata = (builtins.fromJSON (builtins.readFile ./version.json));
in
python3Packages.buildPythonPackage rec {
  pname = "lazyasd";
  version = versiondata.version;
  src = fetchFromGitHub versiondata;
  meta = {
    description = "Lazy & self-destructive tools for speeding up module imports";
    homepage = "https://github.com/xonsh/${pname}";
    license = lib.licenses.mit;
  };
}
