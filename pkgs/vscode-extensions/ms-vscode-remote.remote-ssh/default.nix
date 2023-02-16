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
      version = "0.97.2023021615";
      sha256 = "9baa6b2a5dde7233e8757b1af747ff2e514f0767136ab350c865d3fe1c7ab2de";
    };

    meta = with lib; {
      description = ''
        Open any folder on a remote machine using SSH and take advantage of VS Code's full feature set.
      '';
      license = licenses.mit;
    };
  }
