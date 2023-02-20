#! /usr/bin/env xonsh

# inspired by https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/editors/vscode/extensions/update_installed_exts.sh
# but I like my package definitions explicit, so here we go.

import os
import re
from pathlib import Path

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
  # loop all nix files
  for file in g`**/*.nix`:
    updatevscodeext(Path(file))

def updatevscodeext(path):
  print("Updating vs-code extentions")
  text = path.read_text()

  # Find package name
  re_name = re.search('name.*=.*\"(.*)\"', text)
  assert re_name is not None, "could not find extension name"
  # Find package publisher
  re_publisher = re.search('publisher.*=.*\"(.*)\"', text)
  assert re_publisher is not None, "could not find extension publisher"

  # Extract name and publisher
  name = re_name.group(1)
  publisher = re_publisher.group(1)

  # URL stolen from here
  # https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/editors/vscode/extensions/update_installed_exts.sh
  $URL="https://{0}.gallery.vsassets.io/_apis/public/gallery/publisher/{0}/extension/{1}/latest/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage".format(publisher, name)

  # Create a tempdir for ext download.
  $EXTTMP = $(mktemp -d -t vscode_exts_XXXXXXXX).strip()
  # Name of ZIP file
  $ZIPNAME = "{0}.{1}".format(publisher, name)
  # Full path to download the ZIP file to
  $OUTNAME = "{0}.zip".format(os.path.join($EXTTMP, $ZIPNAME))

  print("Downloading {0}".format($ZIPNAME))
  # Quietly but delicately curl down the file, blowing up at the first sign of trouble.
  curl --silent --show-error --retry 3 --fail -X GET -o "$OUTNAME" "$URL"

  # Get the version number from the package (We downloaded the latest one)
  $VER=$(unzip -qc "$OUTNAME" "extension/package.json" | jq -r '.version').rstrip()
  # Get the SHA for the package
  $SHA=$(nix-hash --flat --type sha256 "$OUTNAME").rstrip()

  # Update version in-place
  text = re.sub('version.*=.*\".*\";', 'version = "{0}";'.format($VER), text)
  # Update sha256 in-place
  text = re.sub('sha256.*=.*\".*\";', 'sha256 = "{0}";'.format($SHA), text)

  # Save new package definition
  path.write_text(text)

  # Remove temporary folder
  rm -rf $OUTNAME

#Call update functions
updatenix()
updatenode()
updatevscode()
nix fmt
