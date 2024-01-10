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
            return match

    return "unknown"


def setlevel(level: str):
    curlevel = getlevel()

    if level != curlevel:
        print(f"setting fanlevel to {level}")
    fanpath.write(f"level {level}")


def gettemp():
    sensordata: dict[str, dict] = json.loads(sensors())
    return float(sensordata["thinkpad-isa-0000"]["CPU"]["temp1_input"])


def setfan(cpu_avg: float, temp: float):
    curtemp = gettemp()
    print("cpu_avg: {}".format(cpu_avg))
    print("temp_avg: {}".format(temp))

    if curtemp > 70:
        setlevel("auto")
        return

    if temp < 60:
        setlevel("0")
    else:
        setlevel("auto")


def main():
    interval: int = 5
    temps = []

    while True:
        temps.append(gettemp())
        if len(temps) > interval:
            temps.pop(0)

        # Keep setting watchdog to not go into auto mode
        setwatchdog(interval + 1)
        setfan(cpu_percent(interval), sum(temps) / len(temps))
        sleep(interval)


if __name__ == "__main__":
    main()
