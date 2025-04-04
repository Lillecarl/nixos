{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
}:
let
  versiondata = builtins.fromJSON (builtins.readFile ./version.json);
in
buildPythonPackage {
  pname = "pyping3";
  version = "0.0.1";
  src = fetchFromGitHub versiondata;

  meta = {
    description = "A pure python ICMP ping implementation using raw sockets";
    homepage = "https://github.com/giokara/pyping/";
    license = lib.licenses.gpl2;
  };
}
