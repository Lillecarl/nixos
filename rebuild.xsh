#! /usr/bin/env xonsh

from pathlib import Path
from time import sleep
import socket

def check_connection(address):
  return !(ping @(address) -c 1 -W 1 > /dev/null)

# Nix might try to rebuild the world if we don't have internet
def block_until_internet(address):
  while not check_connection(address):
    print("No internet, retrying (indefinitely)")
    sleep(1)

def commonargs(buildtype):
  flakepath = "/home/lillecarl/Code/nixos"
  if buildtype == "home-manager" and (socket.gethostname() == "nub" or socket.gethostname() == "shitbox"):
    flakepath += "#lillecarl-gui"
  elif buildtype == "home-manager":
    flakepath += "#lillecarl-term"
  commonargs = ["--flake", flakepath, "--keep-failed", "-v", "--impure"]

  if check_connection("shitbox") and "shitbox" not in socket.gethostname():
    commonargs += ["--builders", "ssh://lillecarl@shitbox?ssh-key=/home/lillecarl/.ssh/id_ed25519"]

  return commonargs



sudo echo "Building nixos"
block_until_internet("1.1.1.1")
print(" ".join(commonargs("nixos")))
nixos-rebuild switch --use-remote-sudo @(commonargs("nixos"))
echo "Building home"
block_until_internet("1.1.1.1")
print(" ".join(commonargs("home-manager")))
home-manager switch -b old @(commonargs("home-manager"))
