#! /usr/bin/env python

from pathlib import Path
from time import sleep
from plumbum import local, FG
from os import environ
import socket

ping = local["ping"]
sudo = local["sudo"]
echo = local["echo"]
virsh = local["virsh"]
nh = local["nh"]

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

sudo[echo["Building nixos"]].run_fg()
if hostname == "shitbox":
    print("Dumping Windows VM XML")
    xml = sudo[virsh["dumpxml", "win10"]]()
    local.path("shitbox/win10.xml").write(xml)
block_until_internet("1.1.1.1")
nh["os", "switch"] & FG  # type: ignore
print("Building home")
block_until_internet("1.1.1.1")
nh["home", "switch", "--", "--impure" ].run_fg()
