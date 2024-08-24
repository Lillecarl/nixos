#! /usr/bin/env python3

# but I like my package definitions explicit, so here we go.

import json
import os
from pathlib import Path

from github import Github
from plumbum import local

git = local["git"]
nix = local["nix"]
nix_prefetch_github_latest_release = local["nix-prefetch-github-latest-release"]
nix_prefetch_url = local["nix-prefetch-url"]
unzip = local["unzip"]
gh = local["gh"]

gdata = list()

# This is expected to run from within my nixos repo
gitroot = git("rev-parse", "--show-toplevel").strip()


def updatenix():
    print("Updating flake inputs")
    # Update nix flake lockfile
    nix["flake", "update", "--flake", gitroot].run_fg()


def updategit():
    os.chdir(os.path.join(gitroot, "pkgs"))

    github = Github(gh("auth", "token").strip())

    for versionfile in local.cwd // "**/version.json":
        versionfile = Path(versionfile)
        versiondata = json.loads(versionfile.read_text())
        print(
            "Fetching updates for {0}/{1}".format(
                versiondata["owner"], versiondata["repo"]
            )
        )
        newdata = json.loads(
            nix_prefetch_github_latest_release(
                "--json", versiondata["owner"], versiondata["repo"]
            )
        )
        if versiondata["rev"] != newdata["rev"]:
            print(
                "Updating {0}/{1} to latest github release".format(
                    newdata["owner"], newdata["repo"]
                )
            )

        try:
            print("Fetching version info from GitHub")
            repo = github.get_repo(
                "{0}/{1}".format(versiondata["owner"], versiondata["repo"])
            )
            newdata["version"] = repo.get_latest_release().tag_name

        except Exception as e:
            print("Couldn't get latest release")
            print(e)

        versionfile.write_text(json.dumps(newdata, indent=2) + os.linesep)


def main():
    updatenix()
    updategit()
    os.chdir(gitroot)
    nix("run", "nixpkgs#statix", "fix")
    nix("fmt")


if __name__ == "__main__":
    main()
