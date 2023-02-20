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
    version = "0.97.2023022015";
    sha256 = "1231f25afc064e8eace0c78be28380a621deff221d973c3323634c332ef1d8b9";
  };

  meta = with lib; {
    description = ''
      Open any folder on a remote machine using SSH and take advantage of VS Code's full feature set.
    '';
    license = licenses.mit;
  };
}
