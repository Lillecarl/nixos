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
      sha256 = "sha256-EhpIzYLn5XdvR5gAd129+KuyTcKFswXtO6WgVT8b+xA=";
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
