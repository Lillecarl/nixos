{ lib
, vscode-utils
}:
let
  inherit (vscode-utils) buildVscodeMarketplaceExtension;
in
buildVscodeMarketplaceExtension {
  mktplcRef = {
    name = "python";
    publisher = "ms-python";
    version = "2023.3.10541008";
    sha256 = "736c4c3911cc69301e2b2d0e1231b7eab05445b494f4cad00a0564c31ec7cff2";
  };

  meta = with lib; {
    description = ''
      IntelliSense (Pylance), Linting, Debugging (multi-threaded, remote), Jupyter Notebooks, code formatting, refactoring, unit tests, and more.
    '';
    license = licenses.mit;
  };
}
