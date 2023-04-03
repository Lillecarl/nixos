#! /usr/bin/env xonsh

# inspired by https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/editors/vscode/extensions/update_installed_exts.sh
# but I like my package definitions explicit, so here we go.

import os
import re
import json
import requests
from github import Github
from pathlib import Path
from plumbum import local

npu = local["nix-prefetch-url"]
npglr = local["nix-prefetch-github-latest-release"]
gdata = list()

# This is expected to run from within my nixos repo
gitroot = $(git rev-parse --show-toplevel).strip()

def updatenix():
  print("Updating flake inputs")
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
    NAME="{0}-{1}.zip".format(ext["publisher"], ext["name"])

    # Download package to nix store
    print("Downloading {0}.{1} to nix store".format(ext["publisher"], ext["name"]))
    prefetch = npu("--name", NAME, "--print-path", URL).splitlines()
    PKGHASH = prefetch[0]
    PKGPATH = prefetch[1]
    $PKGPATH = prefetch[1]
    print(PKGPATH)
    oldver = ext["version"]
    ext["version"] = json.loads($(unzip -qc "$PKGPATH" "extension/package.json"))['version']
    if oldver != ext["version"]:
      print("Updating from {0} to {1}".format(oldver, ext["version"]))
    ext["sha256"] = PKGHASH
    extpath.write_text(json.dumps(data, indent=2) + os.linesep)

def updategit():
  os.chdir(os.path.join(gitroot, "pkgs"))

  gh = Github($(gh auth token).rstrip())

  for versionfile in g`**/version.json`:
    versionfile = Path(versionfile)
    versiondata = json.loads(versionfile.read_text())
    print("Fetching updates for {0}/{1}".format(versiondata["owner"], versiondata["repo"]))
    newdata = json.loads(npglr("--json", versiondata["owner"], versiondata["repo"]))
    if versiondata["rev"] != newdata["rev"]:
      print("Updating {0}/{1} to latest github release".format(newdata["owner"], newdata["repo"]))

    try:
      print("Fetching version info from GitHub")
      repo = gh.get_repo("{0}/{1}".format(versiondata["owner"], versiondata["repo"]))
      newdata["version"] = repo.get_latest_release().tag_name

    except Exception as e:
      print("Couldn't get latest release")
      print(e)

    versionfile.write_text(json.dumps(newdata, indent=2) + os.linesep)

def updateall():
  #Call update functions
  updatenix()
  updatenode()
  updatevscode()
  updategit()
  os.chdir(gitroot)
  nix fmt

if __name__ == '__main__':
  updateall()
