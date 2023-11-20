#! /usr/bin/env python3

from plumbum import local
from plumbum.path.local import LocalPath
from time import time, sleep
from dataclasses import dataclass

notify_send = local["notify-send"]

@dataclass
class State:
    lastNotify: float
    lastPct: int

class Runner:
    def __init__(self):
        self.state = State(0, 0)
        self.state.lastNotify = time()
        self.state.lastPct = self.read_batpct()

    def spin(self):
        while True:
            batpct = self.read_batpct()
            discharging = self.is_discharging()
            sleep(5)

            if not discharging:
                continue

            if time() - self.state.lastNotify < 30:
                continue

            if batpct < 20:
                self.notify(5, batpct)
            elif batpct < 10:
                self.notify(15, batpct)

            self.state.lastNotify = time()

    def notify(self, seconds, percentage):
        notify_send[
                "-t",
                f"{seconds * 1000}",
                "Low battery",
                f"Battery {percentage}"
                ]()

        self.state.lastNotify = time()

    def read_batpct(self):
        return int(local.path("/sys/class/power_supply/BAT0/capacity").read())

    def is_discharging(self):
        return "Discharging" in local.path("/sys/class/power_supply/BAT0/status").read()


if __name__ == "__main__":
    exit(Runner().spin())

