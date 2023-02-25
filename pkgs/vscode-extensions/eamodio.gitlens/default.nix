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
    version = "2023.2.2411";
    sha256 = "6e4b16561305a14eac80f9f72553ad4bdbf37df61f74876a26ac465d367b62e9";
  };

  meta = with lib; {
    description = ''
      Supercharge Git within VS Code — Visualize code authorship at a glance via Git blame annotations and CodeLens, seamlessly navigate and explore Git repositories, gain valuable insights via rich visualizations and powerful comparison commands, and so much more.
    '';
    license = licenses.mit;
  };
}
