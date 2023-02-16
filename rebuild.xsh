#! /usr/bin/env xonsh

from pathlib import Path

flakepath = Path("/home/lillecarl/Code/nixos")

nixos-rebuild build --use-remote-sudo --flake @(flakepath) --keep-failed -v --impure && unlink result
home-manager build --flake @(flakepath) --keep-failed -v --impure && unlink result
nixos-rebuild switch --use-remote-sudo --flake @(flakepath) --keep-failed -v --impure
home-manager switch --flake @(flakepath) --keep-failed -v --impure
