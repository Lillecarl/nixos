#! /usr/bin/env xonsh

# inspired by https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/editors/vscode/extensions/update_installed_exts.sh
# but I like my package definitions explicit, so here we go.

import os
import re
import json
from pathlib import Path
from plumbum import local

npu = local["nix-prefetch-url"]

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
  # chdir into vscode-extensions
  os.chdir(os.path.join(gitroot, "pkgs/vscode-extensions"))

  for dir in g`*`:
    updatevscodeext(dir)

def updatevscodeext(dir):
  print("Updating vs-code extentions")

  publisher = dir.split(".")[0]
  name = dir.split(".")[1]

  # URL stolen from here
  # https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/editors/vscode/extensions/update_installed_exts.sh
  $URL="https://{0}.gallery.vsassets.io/_apis/public/gallery/publisher/{0}/extension/{1}/latest/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage".format(publisher, name)

  print("Downloading {0}.{1}".format(publisher, name))
  # Download package to 
  prefetch = npu("--print-path", $URL).splitlines()
  $PKGHASH = prefetch[0]
  $PKGPATH = prefetch[1]

  # Get the version number from the package (We downloaded the latest one)
  $VER=json.loads($(unzip -qc "$PKGPATH" "extension/package.json"))['version']

  data = {
    "version": $VER,
    "sha256": $PKGHASH
  }

  # Write version JSON
  Path(os.path.join(dir, "version.json")).write_text(json.dumps(data, indent=2) + os.linesep)

#Call update functions
updatenix()
updatenode()
updatevscode()
os.chdir(gitroot)
nix fmt
