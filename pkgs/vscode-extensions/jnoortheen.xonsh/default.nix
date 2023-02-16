{ lib
, vscode-utils
, python3
}:

let
  inherit (vscode-utils) buildVscodeMarketplaceExtension;
in
  buildVscodeMarketplaceExtension {
    mktplcRef = {
      name = "xonsh";
      publisher = "jnoortheen";
      version = "0.2.6";
      sha256 = "121a48cd82e7e5776f479800775dbdf8abb24dc285b305ed3ba5a0553f1bfb10";
    };

    propagatedBuildInputs = with python3.pkgs; [
      python-lsp-server
    ];

    meta = with lib; {
      description = ''
        Xonsh language support.
      '';
      license = licenses.mit;
    };
  }
