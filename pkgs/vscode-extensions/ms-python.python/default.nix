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
    version = "2023.3.10542301";
    sha256 = "4da5b207011a76a0a41e9d67da89054b7fe995c39252131fc1943844ee06fe4c";
  };

  meta = with lib; {
    description = ''
      IntelliSense (Pylance), Linting, Debugging (multi-threaded, remote), Jupyter Notebooks, code formatting, refactoring, unit tests, and more.
    '';
    license = licenses.mit;
  };
}
