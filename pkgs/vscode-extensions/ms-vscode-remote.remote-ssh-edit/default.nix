{ lib
, vscode-utils
}:
let
  inherit (vscode-utils) buildVscodeMarketplaceExtension;
in
  buildVscodeMarketplaceExtension {
    mktplcRef = {
      name = "remote-ssh-edit";
      publisher = "ms-vscode-remote";
      version = "0.84.0";
      sha256 = "sha256-33jHWC8K0TWJG54m6FqnYEotKqNxkcd/D14TFz6dgmc=";
    };

    meta = with lib; {
      description = ''
        Open any folder on a remote machine using SSH and take advantage of VS Code's full feature set.
      '';
      license = licenses.mit;
    };
  }
