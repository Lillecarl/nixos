#! /usr/bin/env xonsh

import os
import re
from pathlib import Path

gitroot = $(git rev-parse --show-toplevel).strip()

def updatenix():
  print("Updating nix")
  nix flake lock --recreate-lock-file @(gitroot)

def updatenode():
  print("Updating node packages")
  os.chdir(os.path.join(gitroot, "pkgs/node-packages"))
  node2nix -i packages.json

def updatevscode():
  os.chdir(os.path.join(gitroot, "pkgs/vscode-extensions"))
  for file in g`**/*.nix`:
    updatevscodeext(Path(file))

def updatevscodeext(path):
  print("Updating vs-code extentions")
  text = path.read_text()

  re_name = re.search('name.*=.*\"(.*)\"', text)
  assert re_name is not None, "could not find extension name"
  re_publisher = re.search('publisher.*=.*\"(.*)\"', text)
  assert re_publisher is not None, "could not find extension publisher"

  name = re_name.group(1)
  publisher = re_publisher.group(1)

  $URL="https://{0}.gallery.vsassets.io/_apis/public/gallery/publisher/{0}/extension/{1}/latest/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage".format(publisher, name)

  # Create a tempdir for ext download.
  $EXTTMP = $(mktemp -d -t vscode_exts_XXXXXXXX).strip()
  $ZIPNAME = "{0}.{1}".format(publisher, name)
  $OUTNAME = "{0}.zip".format(os.path.join($EXTTMP, $ZIPNAME))

  print("Downloading {0}".format($OUTNAME))
  # Quietly but delicately curl down the file, blowing up at the first sign of trouble.
  curl --silent --show-error --retry 3 --fail -X GET -o "$OUTNAME" "$URL"

  $VER=$(unzip -qc "$OUTNAME" "extension/package.json" | jq -r '.version').rstrip()
  $SHA=$(nix-hash --flat --type sha256 "$OUTNAME").rstrip()

  text = re.sub('version.*=.*\".*\";', 'version = "{0}";'.format($VER), text)
  text = re.sub('sha256.*=.*\".*\";', 'sha256 = "{0}";'.format($SHA), text)

  path.write_text(text)

  rm -rf $OUTNAME

updatenix()
updatenode()
updatevscode()
