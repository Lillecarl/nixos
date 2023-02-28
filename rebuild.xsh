#! /usr/bin/env xonsh

from pathlib import Path
from time import sleep
import socket

# Nix might try to rebuild the world if we don't have internet
def block_until_internet():
  while not !(ping 1.1.1.1 -c 1 -W 1 > /dev/null):
    print("No internet, retrying (indefinitely)")
    sleep(1)

def commonargs(buildtype):
  flakepath = "/home/lillecarl/Code/nixos"
  if buildtype == "home-manager" and socket.gethostname() == "nub":
    flakepath += "#lillecarl-gui"
  elif buildtype == "home-manager":
    flakepath += "#lillecarl-term"
  commonargs = ["--flake", flakepath, "--keep-failed", "-v", "--impure"]

  return commonargs



sudo echo "Building nixos"
block_until_internet()
nixos-rebuild switch --use-remote-sudo @(commonargs("nixos"))
echo "Building home"
block_until_internet()
home-manager switch -b old @(commonargs("home-manager"))
