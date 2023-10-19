#! /usr/bin/env python3

import json
import re
import sys
import atexit

from time import sleep, time
from plumbum import local
from psutil import cpu_percent

sensors = local["sensors"]
fanpath = local.path("/proc/acpi/ibm/fan")
_lastwrite = time()

def setwatchdog(sec: int):
    print(f"setting watchdog to {sec}")
    fanpath.write(f"watchdog {sec}")

def getlevel():
    faninfo: str = fanpath.read()
    faninfolines = faninfo.splitlines()

    for line in faninfolines:
        regex = r"^level:\s*(.*)$"
        matches = re.match(regex, line)
        if matches:
            match = matches.group(1)
            if match == "disengaged":
                return 8
            elif match == "auto":
                return 0
            else:
                return int(match)

    return 0


def setlevel(level: int, force: bool = False):
    global _lastwrite
    curlevel = getlevel()

    if level > 8:
        level = 8
    elif level < 0:
        level = 0

    # Always transition through level 1 before 0
    if curlevel > 1 and level == 0:
        level = 1

    if level == curlevel and not force:
        return False

    if time() - _lastwrite < 5 and not force:
        return False

    print(f"setting fanlevel to {level}")

    if level == 8:
        fanpath.write("level full-speed")
    else:
        fanpath.write(f"level {level}")

    _lastwrite = time()

    return True

def gettemp():
    sensordata: dict[str, dict] = json.loads(sensors["-j"]())
    return float(sensordata["thinkpad-isa-0000"]["CPU"]["temp1_input"])

def getspeed():
    sensordata: dict[str, dict] = json.loads(sensors["-j"]())
    return float(sensordata["thinkpad-isa-0000"]["fan1"]["fan1_input"])

def setfan(cpu_avg: float):
    level = getlevel()
    temp = gettemp()

    print("cpu_avg: {}".format(cpu_avg))

    if temp < 55:
        return setlevel(0)
    elif temp > 55 and cpu_avg > 20:
        if cpu_avg > 25:
            return setlevel(level + 1)
        else:
            setlevel(level + 2)
    elif temp > 65:
        return setlevel(level + 1)
    elif cpu_avg < 3:
        return setlevel(level - 2)
    else:
        return setlevel(level - 1)

def main():
    setwatchdog(0)
    setlevel(0, True)
    fan_counter: int = 0
    fan_interval: int = 5

    cpu_total: float = 0

    while True:
        sleep(1)
        cpu_pct = cpu_percent()
        print("cpu_pct: {} fan_counter: {}".format(
            cpu_pct,
            fan_counter,
            ))

        fan_counter += 1
        cpu_total = cpu_total + cpu_pct

        if fan_counter >= 5:
            cpu_avg: float = cpu_total / fan_interval
            setfan(cpu_avg)
            fan_counter = 0
            cpu_total = 0

def excepthook(type, value, tb):
    setwatchdog(120)
sys.excepthook = excepthook

@atexit.register
def on_exit():
    setwatchdog(120)

if __name__ == "__main__":
    exit(main())
