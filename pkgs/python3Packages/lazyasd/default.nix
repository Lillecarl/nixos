{ lib
, python3Packages
}:

python3Packages.buildPythonPackage rec {
  pname = "lazyasd";
  version = "0.1.4";
  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "sha256-oxlvBc/yf5Uq0Fdn5XNf1WS06k6Jsj9eoYhyKcPbFFs=";
  };

  meta = {
    description = "Lazy & self-destructive tools for speeding up module imports";
    homepage = "https://github.com/xonsh/${pname}";
    license = lib.licenses.mit;
  };
}
