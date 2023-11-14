#! /usr/bin/env python3

from plumbum import local
from plumbum.path.local import LocalPath
from time import time, sleep

import json

def main():
    state = {
        "lastNotify": time()
    }

    notify_send = local["notify-send"]

    while True:
        batpct = int(local.path("/sys/class/power_supply/BAT0/capacity").read())
        discharging = "Discharging" in local.path("/sys/class/power_supply/BAT0/status").read()
        sleep(5)

        if not discharging:
            continue

        if time() - state["lastNotify"] < 30:
            continue

        if batpct < 20:
            notify_send[
                    "-t",
                    "1000",
                    "Low battery",
                    f"Battery {batpct}"
                    ]()
        elif batpct < 10:
            notify_send[
                    "-t",
                    "10000",
                    "Low battery",
                    f"Battery {batpct}"
                    ]()

        state["lastNotify"] = time()


if __name__ == "__main__":
    main()

