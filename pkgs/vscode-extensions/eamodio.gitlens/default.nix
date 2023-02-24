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
    version = "2023.2.2404";
    sha256 = "73ed95e57ca01773f8dccf538af7c12a380d93acad89438c0c2b039cc8a1c828";
  };

  meta = with lib; {
    description = ''
      Supercharge Git within VS Code — Visualize code authorship at a glance via Git blame annotations and CodeLens, seamlessly navigate and explore Git repositories, gain valuable insights via rich visualizations and powerful comparison commands, and so much more.
    '';
    license = licenses.mit;
  };
}
