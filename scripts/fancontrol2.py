#! /usr/bin/env python3

import json
import re
from time import time

from plumbum import local
from psutil import cpu_percent

sensors = local["sensors"]["-j"]
fanpath = local.path("/proc/acpi/ibm/fan")

config = {
    # How often we probe the system
    "interval": 5,
    # How long to wait between changes from auto to off or vice versa
    "change_wait": 30,
    # The temperature at which we turn off the fan
    "low_temp": 60,
    # The temperature at which we turn on the fan regardless of average
    "high_temp": 70,
    # The cpu usage at which we turn on the fan, averaged over interval * 2 seconds
    "high_cpu": 25,
}


def setwatchdog(sec: int):
    sec = min(sec, 120)  # Max watchdog time is 120 seconds
    fanpath.write(f"watchdog {sec}")


def isenabled():
    faninfo: str = fanpath.read()
    faninfolines = faninfo.splitlines()

    for line in faninfolines:
        regex = r"^status:\s*(.*)$"
        matches = re.match(regex, line)
        if matches:
            match = matches.group(1)
            if "enabled" in match:
                return True
            elif "disabled" in match:
                return False

    return False  # type saftey


def gettemp():
    sensordata: dict[str, dict] = json.loads(sensors())
    return float(sensordata["thinkpad-isa-0000"]["CPU"]["temp1_input"])


def setonoff(enable: bool):
    setwatchdog(config["interval"] + 1)
    command = "enable" if enable else "disable"

    ret = False
    if enable != isenabled():
        print(f"{command} fan")
        ret = True
    else:
        print(f"watchdog {command} fan")

    if enable:
        fanpath.write("level auto")
    else:
        fanpath.write("level 0")

    return ret


def enable():
    return setonoff(True)


def disable():
    return setonoff(False)


def setfan(cpu_avg: float, temp_avg: float, last_change: float):
    global config

    cur_temp = gettemp()
    print(f"cur_temp: {cur_temp}")
    print(f"cpu_avg: {cpu_avg}")
    print(f"temp_avg: {temp_avg}")

    if cur_temp > config["high_temp"]:
        return enable()
    elif cpu_avg > config["high_cpu"]:
        return enable()

    if time() - last_change < config["change_wait"]:
        return setonoff(isenabled())

    if temp_avg < config["low_temp"]:
        return disable()

    return enable()


def main():
    global config

    temps = []
    last_change = time() - config["change_wait"]
    last_cpu = cpu_percent(1)

    while True:
        temps.append(gettemp())
        if len(temps) > config["change_wait"] / config["interval"]:
            temps.pop(0)

        temp_avg = sum(temps) / len(temps)
        # cpu_percent also sleeps for the fetching interval
        cpu_avg = (cpu_percent(config["interval"]) + last_cpu) / 2

        # Don't spam between off and auto
        if setfan(cpu_avg, temp_avg, last_change):
            last_change = time()

        last_cpu = cpu_avg


if __name__ == "__main__":
    main()
