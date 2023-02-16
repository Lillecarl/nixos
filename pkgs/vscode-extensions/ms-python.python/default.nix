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
      sha256 = "94dfa17f79a8bb522ebcfdf6da493ccb347c7935c3d34e070a560953c338b33a";
    };

    meta = with lib; {
      description = ''
        IntelliSense (Pylance), Linting, Debugging (multi-threaded, remote), Jupyter Notebooks, code formatting, refactoring, unit tests, and more.
      '';
      license = licenses.mit;
    };
  }
