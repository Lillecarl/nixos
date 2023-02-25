#! /usr/bin/env xonsh

# inspired by https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/editors/vscode/extensions/update_installed_exts.sh
# but I like my package definitions explicit, so here we go.

import os
import re
import json
from pathlib import Path
from plumbum import local

npu = local["nix-prefetch-url"]
gdata = list()

# This is expected to run from within my nixos repo
gitroot = $(git rev-parse --show-toplevel).strip()

def updatenix():
  print("Updating nix")
  # Update nix flake lockfile
  nix flake lock --recreate-lock-file @(gitroot)

def updatenode():
  print("Updating node packages")
  # chdir into node-packages
  os.chdir(os.path.join(gitroot, "pkgs/node-packages"))
  node2nix -i packages.json

def updatevscode():
  os.chdir(gitroot)
  extpath = Path(os.path.join(gitroot, "pkgs", "vscodeExtensions.json"))
  data = json.loads(extpath.read_text())

  for ext in data:
    URL="https://{0}.gallery.vsassets.io/_apis/public/gallery/publisher/{0}/extension/{1}/latest/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage".format(ext["publisher"], ext["name"])

    # Download package to nix store
    print("Downloading {0}.{1} to nix store".format(ext["publisher"], ext["name"]))
    prefetch = npu("--print-path", URL).splitlines()
    $PKGHASH = prefetch[0]
    $PKGPATH = prefetch[1]
    ext["version"] = json.loads($(unzip -qc "$PKGPATH" "extension/package.json"))['version']
    ext["sha256"] = $PKGHASH
    Path(os.path.join(gitroot, "pkgs", "vscodeExtensions.json")).write_text(json.dumps(data, indent=2))

#Call update functions
#updatenix()
#updatenode()
updatevscode()
nix fmt

