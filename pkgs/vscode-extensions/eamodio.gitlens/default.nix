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
      version = "2023.2.1604";
      sha256 = "b560d38655231a77789a70805e1701783fa77abc45d5b35e8788bcb535d46127";
    };

    meta = with lib; {
      description = ''
        Supercharge Git within VS Code — Visualize code authorship at a glance via Git blame annotations and CodeLens, seamlessly navigate and explore Git repositories, gain valuable insights via rich visualizations and powerful comparison commands, and so much more.
      '';
      license = licenses.mit;
    };
  }
