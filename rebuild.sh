#! /usr/bin/env xonsh

from pathlib import Path

flakepath = Path("/home/lillecarl/Code/nixos")

nixos-rebuild switch --use-remote-sudo --flake @(flakepath) --keep-failed -v --impure
home-manager switch --flake @(flakepath) --keep-failed -v --impure
