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
    sha256 = "df78c7582f0ad135891b9e26e85aa7604a2d2aa37191c77f0f5e13173e9d8267";
  };

  meta = with lib; {
    description = ''
      Open any folder on a remote machine using SSH and take advantage of VS Code's full feature set.
    '';
    license = licenses.mit;
  };
}
