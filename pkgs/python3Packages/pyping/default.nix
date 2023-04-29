{ lib
, python3Packages
, fetchFromGitHub
,
}:
let
  versiondata = builtins.fromJSON (builtins.readFile ./version.json);
in
python3Packages.buildPythonPackage rec {
  pname = "pyping3";
  version = versiondata.version;
  src = fetchFromGitHub versiondata;

  meta = {
    description = "A pure python ICMP ping implementation using raw sockets";
    homepage = "https://github.com/giokara/pyping/";
    license = lib.licenses.gpl2;
  };
}
