#! /usr/bin/env python3

from pathlib import Path
from plumbum import local

systemctl = local["systemctl"]

# Contains status about our laptop battery
batstat = Path("/sys/class/power_supply/BAT0/status").read_text()

if batstat.find("Discharging") != -1:
    print("Suspending")
    systemctl(["suspend"])
else:
    print("Not suspending, we're not discharging")
