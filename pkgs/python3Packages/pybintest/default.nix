{ lib
, python3Packages
}:
python3Packages.buildPythonPackage {
  pname = "pylib";
  version = "0.0.1";

  src = ./.;

  propagatedBuildInputs = with python3Packages; [ plumbum ];

  meta = {
    description = "A package that uses plumbum to call ls";
    license = lib.licenses.gpl2;
  };
}
