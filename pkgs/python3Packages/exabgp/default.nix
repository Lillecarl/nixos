{ lib
, python3Packages
, fetchFromGitHub
,
}:
let
  versiondata = builtins.fromJSON (builtins.readFile ./version.json);
in
python3Packages.buildPythonPackage rec {
  pname = "exabgp";
  version = versiondata.version;
  src = fetchFromGitHub versiondata;

  meta = {
    description = "The BGP swiss army knife of networking";
    homepage = "https://github.com/Exa-Networks/exabgp";
    license = lib.licenses.bsd3;
  };
}
