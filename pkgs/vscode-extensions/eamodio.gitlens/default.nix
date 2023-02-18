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
      version = "2023.2.1804";
      sha256 = "16b081657d51fe0808cbfc2e321925250408ad1e0bf11344b848440cabbbacc5";
    };

    meta = with lib; {
      description = ''
        Supercharge Git within VS Code — Visualize code authorship at a glance via Git blame annotations and CodeLens, seamlessly navigate and explore Git repositories, gain valuable insights via rich visualizations and powerful comparison commands, and so much more.
      '';
      license = licenses.mit;
    };
  }
