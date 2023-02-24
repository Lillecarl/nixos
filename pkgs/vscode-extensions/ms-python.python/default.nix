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
    version = "2023.3.10551009";
    sha256 = "9cf46e08b936f47a57c7e8ee8ac4cffddb7b4f019453d15a8bbde914aa7e4450";
  };

  meta = with lib; {
    description = ''
      IntelliSense (Pylance), Linting, Debugging (multi-threaded, remote), Jupyter Notebooks, code formatting, refactoring, unit tests, and more.
    '';
    license = licenses.mit;
  };
}
