{ lib
, vscode-utils
, python3
}:

let
  inherit (vscode-utils) buildVscodeMarketplaceExtension;
  versioninfo = (builtins.fromJSON (builtins.readFile ./version.json));
in
buildVscodeMarketplaceExtension {
  mktplcRef = {
    name = "xonsh";
    publisher = "jnoortheen";
    version = versioninfo.version;
    sha256 = versioninfo.sha256;
  };

  propagatedBuildInputs = with python3.pkgs; [
    python-lsp-server
  ];

  meta = with lib; {
    description = ''
      Xonsh language support.
    '';
    license = licenses.mit;
  };
}
