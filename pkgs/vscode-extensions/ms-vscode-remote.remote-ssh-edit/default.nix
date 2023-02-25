{ lib
, vscode-utils
}:
let
  inherit (vscode-utils) buildVscodeMarketplaceExtension;
  versioninfo = (builtins.fromJSON (builtins.readFile ./version.json));
in
buildVscodeMarketplaceExtension {
  mktplcRef = {
    name = "remote-ssh-edit";
    publisher = "ms-vscode-remote";
    version = versioninfo.version;
    sha256 = versioninfo.sha256;
  };

  meta = with lib; {
    description = ''
      Open any folder on a remote machine using SSH and take advantage of VS Code's full feature set.
    '';
    license = licenses.mit;
  };
}
