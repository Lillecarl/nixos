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
  flakepath = "/home/lillecarl/Code/nixos"
  Path(os.path.join(flakepath, ".flakepath")).write_text(flakepath)
  git update-index --skip-worktree ".flakepath"
  commonargs = ["--flake", flakepath, "--keep-failed", "-v", "--impure"]

  #if check_connection("shitbox") and "shitbox" not in hostname:
    #commonargs += ["--builders", "ssh://lillecarl@shitbox?ssh-key=/home/lillecarl/.ssh/id_ed25519"]
    #commonargs += ["--builders", "ssh://lillecarl@shitbox x86_64-linux"]

  return commonargs

sudo echo "Building nixos"
if hostname == "shitbox":
  sudo virsh dumpxml win10 > ./shitbox/win10.xml
block_until_internet("1.1.1.1")
nixos-rebuild switch --use-remote-sudo @(commonargs("nixos"))
echo "Building home"
block_until_internet("1.1.1.1")
home-manager switch -b old @(commonargs("home-manager"))
