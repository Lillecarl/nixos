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
    version = "0.97.2023022415";
    sha256 = "5e8bf3b3d5855f8327ca0eb381805e6344fb5824a3dbaf3e51990f24f7402e6f";
  };

  meta = with lib; {
    description = ''
      Open any folder on a remote machine using SSH and take advantage of VS Code's full feature set.
    '';
    license = licenses.mit;
  };
}
