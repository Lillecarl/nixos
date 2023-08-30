#! /usr/bin/env python

from pathlib import Path
from time import sleep
from plumbum import local, BG, FG
from os import environ
import socket

ping = local["ping"]
sudo = local["sudo"]
echo = local["echo"]
virsh = local["virsh"]
nixos_rebuild = local["nixos-rebuild"]
home_manager = local["home-manager"]

hostname = socket.gethostname()

def check_connection(address):
    try:
        ping(address, "-c", "1", "-W", "1")
        return True
    except:
        pass

    return False

# Nix might try to rebuild the world if we don't have internet
def block_until_internet(address):
  while not check_connection(address):
    print("No internet, retrying (indefinitely)")
    sleep(1)

def commonargs(buildtype):
  commonargs = ["--flake", environ["FLAKELOC"], "--keep-failed", "-v", "--impure"]

  return commonargs

sudo[echo["Building nixos"]] & FG
if hostname == "shitbox":
    print("Dumping Windows VM XML")
    (sudo(virsh("dumpxml", "win10") > "./shitbox/win10.xml"))
block_until_internet("1.1.1.1")
nixos_rebuild["switch", "--use-remote-sudo", commonargs("nixos")] & FG
print("Building home")
block_until_internet("1.1.1.1")
home_manager["switch", "-b", "old", commonargs("home-manager")] & FG
