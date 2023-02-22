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
    version = "2023.3.10531009";
    sha256 = "520efac6497c96282c845d75c24b47d39b183df9d7df16ffff01cbf3d442bf76";
  };

  meta = with lib; {
    description = ''
      IntelliSense (Pylance), Linting, Debugging (multi-threaded, remote), Jupyter Notebooks, code formatting, refactoring, unit tests, and more.
    '';
    license = licenses.mit;
  };
}
