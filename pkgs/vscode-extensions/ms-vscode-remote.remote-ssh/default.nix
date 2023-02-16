{ lib
, vscode-utils
}:
let
  inherit (vscode-utils) buildVscodeMarketplaceExtension;
in
  buildVscodeMarketplaceExtension {
    mktplcRef = {
      name = "remote-ssh";
      publisher = "ms-vscode-remote";
      version = "0.97.2023020215";
      sha256 = "9ca8402184b67a429456b8c45b5756c9f91cce8477805e542a39850a39d1c047";
    };

    meta = with lib; {
      description = ''
        Open any folder on a remote machine using SSH and take advantage of VS Code's full feature set.
      '';
      license = licenses.mit;
    };
  }
