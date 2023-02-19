#! /usr/bin/env xonsh

from pathlib import Path
from time import sleep

# Nix might try to rebuild the world if we don't have internet
def block_until_internet():
  while not !(ping 1.1.1.1 -c 1 -W 1 > /dev/null):
    print("No internet, retrying (indefinitely)")
    sleep(1)

flakepath = Path("/home/lillecarl/Code/nixos")
commonargs = ["--flake", flakepath, "--keep-failed", "-v", "--impure"]

sudo echo "Building nixos"
block_until_internet()
nixos-rebuild switch --use-remote-sudo @(commonargs)
echo "Building home"
block_until_internet()
home-manager switch -b old @(commonargs)
