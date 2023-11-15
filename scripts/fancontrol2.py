#! /usr/bin/env python3

import json
import re
import sys
import atexit

from time import sleep, time
from plumbum import local
from psutil import cpu_percent

sensors = local["sensors"]["-j"]

hwmon_root = local.path("/sys/bus/platform/drivers/thinkpad_hwmon/thinkpad_hwmon/hwmon/hwmon1")
hwmon_path = hwmon_root / "pwm1"

fanpath = local.path("/proc/acpi/ibm/fan")

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
            elif match == "disabled":
                return 0
            elif match == "auto":
                return -1
            else:
                return int(match)

    return 0


def setlevel(level: int, force: bool = False):
    curlevel = getlevel()

    if level > 7:
        level = 7
    elif level < 0:
        level = 0

    if curlevel > 1 and level == 0:
        level = 1

    if level == 0 and getspeed() == 0 and not force:
        return False

    if level == curlevel and not force:
        return False

    if level > 0:
        print(f"setting fanlevel to {level}")
        fanpath.write(f"level {level}")
    else:
        u8level = int((255 / 7) * level)
        print(f"setting pwmlevel to {u8level}")
        hwmon_path.write(str(u8level))

    return True

def gettemp():
    sensordata: dict[str, dict] = json.loads(sensors())
    return float(sensordata["thinkpad-isa-0000"]["CPU"]["temp1_input"])

def getspeed():
    sensordata: dict[str, dict] = json.loads(sensors())
    return float(sensordata["thinkpad-isa-0000"]["fan1"]["fan1_input"])

def setfan(cpu_avg: float):
    level = getlevel()
    temp = gettemp()

    print("cpu_avg: {}".format(cpu_avg))

    # Reset watchdog, we're in auto and must set a level to
    # get into manual mode
    if getlevel() < 0 and getspeed() > 0:
        setlevel(1)
        return 1

    if temp < 55:
        return setlevel(0)
    elif temp > 55 and cpu_avg > 20:
        return setlevel(level + 1)
    elif temp > 65:
        return setlevel(level + 1)
    elif cpu_avg < 3:
        return setlevel(level - 2)
    else:
        return setlevel(level - 1)

def main():
    setwatchdog(120)
    setlevel(0, True)

    while True:
        sleep(5)
        setfan(cpu_percent(5))

if __name__ == "__main__":
    exit(main())
