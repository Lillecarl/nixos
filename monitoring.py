#! /usr/bin/env python3

import sqlite3
import psutil
import time
import re
import json

from plumbum import local

sudo        = local["sudo"]
sensors     = local["sensors"]["-j"]
rdmsr       = local["rdmsr"]
readwatt    = rdmsr["-p", "0", "0xC001029B", "-d"]

def create_connection(db_file):
    """ create a database connection to the SQLite database
        specified by db_file
    :param db_file: database file
    :return: Connection object or None
    """
    conn = None
    try:
        conn = sqlite3.connect(db_file)
        return conn
    except sqlite3.Error as e:
        print(e)

    return conn

def get_energy_unit():
    data = int(rdmsr("-p", "0", "0xC0010299", "-d"))

    return float(pow(1.0 / 2.0, float((data >> 8) & 0x1F)))

def main():
    conn = create_connection("/var/lib/grafana/data/monitoring.sqlite3")

    if not conn:
        return

    conn.execute('pragma journal_mode=wal')

    conn.execute("""CREATE TABLE IF NOT EXISTS
                 cpu(
                    time INTEGER PRIMARY KEY,
                    value REAL
                 )
                 STRICT;""")
    conn.execute("""CREATE TABLE IF NOT EXISTS
                 fan(
                    time INTEGER PRIMARY KEY,
                    value REAL
                 )
                 STRICT;""")
    conn.execute("""CREATE TABLE IF NOT EXISTS
                 temp(
                    time INTEGER PRIMARY KEY,
                    value REAL
                 )
                 STRICT;""")
    conn.execute("""CREATE TABLE IF NOT EXISTS
                 power(
                    time INTEGER PRIMARY KEY,
                    value REAL
                 )
                 STRICT;""")

    conn.commit()

    batpath = local.path("/sys/class/power_supply/BAT0/")

    owatt = float(readwatt())
    otime = time.time()

    energy_unit = get_energy_unit()

    while True:
        time.sleep(1)

        nwatt = float(readwatt())
        ntime = time.time()

        dtime = ntime - otime

        watt = ((nwatt - owatt) / dtime) * energy_unit

        data = json.loads(sensors())

        ctime: int = int(time.time())
        cpu_pct: float = float(psutil.cpu_percent(interval=1))
        fan_speed: float = float(data["thinkpad-isa-0000"]["fan1"]["fan1_input"])
        cpu_temp: float = float(data["thinkpad-isa-0000"]["CPU"]["temp1_input"])
        charging: bool = "Charging" in (batpath / "status").read()
        power_now: float = float((batpath / "power_now").read()) / 1000000

        if not charging:
            power_now = -power_now

        print(f"cpu_pct: {cpu_pct}")
        print(f"fan_speed: {fan_speed}")
        print(f"cpu_temp: {cpu_temp}")
        print(f"power_now: {power_now}")
        print(f"watt: {watt}")
        print(f"dtime: {dtime}")

        conn.execute("""INSERT INTO
                            cpu
                            (
                                time,
                                value
                            )
                            VALUES
                            (
                                ?,
                                ?
                            )""",
                            (
                                ctime,
                                cpu_pct
                            )
                     )

        conn.execute("""INSERT INTO
                            fan
                            (
                                time,
                                value
                            )
                            VALUES
                            (
                                ?,
                                ?
                            )""",
                            (
                                ctime,
                                float(fan_speed)
                            )
                     )

        conn.execute("""INSERT INTO
                            temp
                            (
                                time,
                                value
                            )
                            VALUES
                            (
                                ?,
                                ?
                            )""",
                            (
                                ctime,
                                float(cpu_temp)
                            )
                     )
        conn.execute("""INSERT INTO
                            power
                            (
                                time,
                                value
                            )
                            VALUES
                            (
                                ?,
                                ?
                            )""",
                            (
                                ctime,
                                float(power_now)
                            )
                     )
        conn.commit()

        # Set old values to new for next iteration
        owatt = nwatt
        otime = ntime

if __name__ == "__main__":
    main()
