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
      version = "2023.3.10461028";
      sha256 = "sha256-lN+hf3mou1IuvP322kk8yzR8eTXD004HClYJU8M4szo=";
    };

    meta = with lib; {
      description = ''
        IntelliSense (Pylance), Linting, Debugging (multi-threaded, remote), Jupyter Notebooks, code formatting, refactoring, unit tests, and more.
      '';
      license = licenses.mit;
    };
  }
