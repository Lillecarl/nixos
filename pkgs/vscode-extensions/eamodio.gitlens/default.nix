{ lib
, vscode-utils
}:
let
  inherit (vscode-utils) buildVscodeMarketplaceExtension;
in
  buildVscodeMarketplaceExtension {
    mktplcRef = {
      name = "gitlens";
      publisher = "eamodio";
      version = "2023.2.1904";
      sha256 = "0a68f099cc1cfc84ea91976357b6eb9b41e4237425a6bf5e32e7d93c363e964d";
    };

    meta = with lib; {
      description = ''
        Supercharge Git within VS Code — Visualize code authorship at a glance via Git blame annotations and CodeLens, seamlessly navigate and explore Git repositories, gain valuable insights via rich visualizations and powerful comparison commands, and so much more.
      '';
      license = licenses.mit;
    };
  }
