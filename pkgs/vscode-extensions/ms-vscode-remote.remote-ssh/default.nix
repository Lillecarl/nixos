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
      sha256 = "sha256-nKhAIYS2ekKUVrjEW1dWyfkczoR3gF5UKjmFCjnRwEc=";
    };

    meta = with lib; {
      description = ''
        Open any folder on a remote machine using SSH and take advantage of VS Code's full feature set.
      '';
      license = licenses.mit;
    };
  }
