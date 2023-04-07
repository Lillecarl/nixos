{ lib
, fetchFromGitHub
, buildPythonPackage
, setuptools
, six

, bridge-utils
, busybox
, dpkg
, ethtool
, iproute2
, kmod
, mstpd
, openvswitch
, ppp
, procps
, pstree
, service-wrapper
, systemd
}:
let
  versiondata = (builtins.fromJSON (builtins.readFile ./version.json));
in
buildPythonPackage rec {
  pname = "ifupdown2";
  version = "3.0.0-1";
  src = fetchFromGitHub versiondata;

  propagatedBuildInputs = [
    setuptools
    six

    bridge-utils
    busybox
    dpkg
    ethtool
    iproute2
    kmod
    mstpd
    openvswitch
    ppp
    procps
    pstree
    service-wrapper
    systemd
  ];

  meta = {
    description = "Linux Interface Network Manager 2";
    homepage = "https://github.com/Lillecarl/ifupdown2";
    license = lib.licenses.gpl2;
  };
}
