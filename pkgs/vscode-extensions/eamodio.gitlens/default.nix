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
    version = "2023.2.2312";
    sha256 = "48ae5703693d4728e1d735a1ed867586ab41e2e8d5a0a5f8721dbcb7ea3a43fb";
  };

  meta = with lib; {
    description = ''
      Supercharge Git within VS Code — Visualize code authorship at a glance via Git blame annotations and CodeLens, seamlessly navigate and explore Git repositories, gain valuable insights via rich visualizations and powerful comparison commands, and so much more.
    '';
    license = licenses.mit;
  };
}
