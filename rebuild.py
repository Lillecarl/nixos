#! /usr/bin/env python

from time import sleep
from plumbum import local, FG
import socket

ping = local["ping"]
sudo = local["sudo"]
echo = local["echo"]
virsh = local.get("virsh", "echo")
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

if text := (local.cwd / "flake.nix").read():
    if "?rev=" in text:
        print("LOCKED FLAKE INPUTS")

sudo[echo["Building nixos"]].run_fg()
if hostname == "shitbox":
    print("Dumping Windows VM XML")
    xml = sudo[virsh["dumpxml", "win10"]]()
    local.path("hosts/shitbox/win10.xml").write(xml)
block_until_internet("1.1.1.1")

try:
    nh["os", "switch", "--", "--impure" ] & FG  # type: ignore
except:
    print("Failed to build nixos")
    exit(1)

print("Building home")
block_until_internet("1.1.1.1")
try:
    nh["home", "switch", "--", "--impure" ].run_fg()
except:
    print("Failed to build home-manager")
    exit(1)
