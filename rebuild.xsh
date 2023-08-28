#! /usr/bin/env xonsh

from pathlib import Path
from time import sleep
import socket

hostname = socket.gethostname()

def check_connection(address):
  return !(ping @(address) -c 1 -W 1 > /dev/null)

# Nix might try to rebuild the world if we don't have internet
def block_until_internet(address):
  while not check_connection(address):
    print("No internet, retrying (indefinitely)")
    sleep(1)

def commonargs(buildtype):
  commonargs = ["--flake", $FLAKELOC, "--keep-failed", "-v", "--impure"]

  return commonargs

sudo echo "Building nixos"
if hostname == "shitbox":
  sudo virsh dumpxml win10 > ./shitbox/win10.xml
block_until_internet("1.1.1.1")
nixos-rebuild switch --use-remote-sudo @(commonargs("nixos"))
echo "Building home"
block_until_internet("1.1.1.1")
home-manager switch -b old @(commonargs("home-manager"))
