{ lib
, python3Packages
, fetchPypi
}:
let
  pname = "hyprpy";
  version = "0.1.5";
  format = "wheel";
in
python3Packages.buildPythonPackage {
  inherit pname version;
  src = fetchPypi rec {
    inherit pname version format;
    sha256 = "sha256-+yf0VDCqX8QPKjFz7r37sgZBdsBW6EJ4oVbq1PDW7IY=";
    dist = python;
    python = "py3";
    #abi = "none";
    #platform = "any";
  };
}

#python3Packages.buildPythonPackage {
#  inherit pname version;
#  #pyproject = true;
#
#  src = fetchPypi {
#    inherit pname version;
#    hash = "sha256-yyPPnIc1CXL3Aqo6q+45uMNfU8DeUxjRgScruqDIJHA=";
#  };
#
#  meta = {
#    description = "Hyprland IPC";
#    homepage = "https://github.com/ulinja/hyprpy";
#    license = lib.licenses.mit;
#  };
#}
