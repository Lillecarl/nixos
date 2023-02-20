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
    version = "2023.2.2004";
    sha256 = "609c2a283e498353f34175904738d241baf901931e136a882ccff06539d723f7";
  };

  meta = with lib; {
    description = ''
      Supercharge Git within VS Code — Visualize code authorship at a glance via Git blame annotations and CodeLens, seamlessly navigate and explore Git repositories, gain valuable insights via rich visualizations and powerful comparison commands, and so much more.
    '';
    license = licenses.mit;
  };
}
