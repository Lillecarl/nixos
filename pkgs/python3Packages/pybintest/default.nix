{
  lib,
  buildPythonPackage,
  plumbum,
}:
buildPythonPackage {
  pname = "pylib";
  version = "0.0.1";

  src = ./.;

  propagatedBuildInputs = [ plumbum ];

  meta = {
    description = "A package that uses plumbum to call ls";
    license = lib.licenses.gpl2;
  };
}
