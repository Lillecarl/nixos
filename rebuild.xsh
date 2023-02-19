#! /usr/bin/env xonsh

from pathlib import Path

flakepath = Path("/home/lillecarl/Code/nixos")
commonargs = ["--flake", flakepath, "--keep-failed", "-v", "--impure"]

sudo echo "Building nixos"
nixos-rebuild switch --use-remote-sudo @(commonargs)
echo "Building home"
home-manager switch -b old @(commonargs)
