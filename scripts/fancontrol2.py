#! /usr/bin/env python3

import json
import re
from time import sleep

from plumbum import local
from psutil import cpu_percent

sensors = local["sensors"]["-j"]
fanpath = local.path("/proc/acpi/ibm/fan")


def setwatchdog(sec: int = 120):
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


def setlevel(level: int):
    curlevel = getlevel()

    if level > 7:
        level = 7
    elif level < 0:
        level = 0

    if level != curlevel:
        print(f"setting fanlevel to {level}")
    fanpath.write(f"level {level}")


def setauto():
    fanpath.write(f"level auto")


def gettemp():
    sensordata: dict[str, dict] = json.loads(sensors())
    return float(sensordata["thinkpad-isa-0000"]["CPU"]["temp1_input"])


def getspeed():
    sensordata: dict[str, dict] = json.loads(sensors())
    return float(sensordata["thinkpad-isa-0000"]["fan1"]["fan1_input"])


def setfan(cpu_avg: float):
    temp = gettemp()

    print("cpu_avg: {}".format(cpu_avg))

    if temp < 60:
        setlevel(0)
    else:
        setauto()


def main():
    interval: int = 5

    while True:
        setwatchdog(interval + 1)
        setfan(cpu_percent(interval))
        sleep(interval)


if __name__ == "__main__":
    main()
